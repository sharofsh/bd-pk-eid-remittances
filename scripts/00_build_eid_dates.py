# Builds data/eid_dates.csv from the hand-collected source log (data/eid_dates_sources_raw.tsv).
# Unsourced events fall back to the Umm al-Qura date and are flagged.
# Requires: pip install hijri-converter==2.3.*   Run from repo root: python3 scripts/00_build_eid_dates.py
import csv, sys
from datetime import date
from hijri_converter import Hijri
notes = list(csv.DictReader(open("data/eid_dates_sources_raw.tsv"), delimiter='\t'))
src = {}
for r in notes:
    k=(r['country'],r['event'],int(r['hijri']))
    if k in src:
        assert src[k]['date']==r['date'], (k, src[k]['date'], r['date'])
        src[k]['source'] += ' ; ' + r['source']
        src[k]['note'] = (src[k]['note'] + ' ; ' + r['note']).strip(' ;')
    else:
        src[k]=dict(r)
# holiday-only evidence (kept as notes for fallback rows)
holiday = {
 ('PK','Fitr',1430):'SBP BPRD CL28/2009: banks closed 21-23 Sep 2009 https://www.sbp.org.pk/bprd/2009/CL28.htm',
 ('PK','Fitr',1428):'SBP BPRD CL34/2007: banks closed 13-16 Oct 2007 https://www.sbp.org.pk/bprd/2007/CL34.htm',
 ('PK','Fitr',1429):'SBP BPRD CL27/2008: banks closed 1-3 Oct 2008 https://www.sbp.org.pk/bprd/2008/CL27.htm',
 ('PK','Fitr',1426):'SBP BPD CL43/2005: banks closed 3-5 Nov 2005 https://www.sbp.org.pk/bpd/2005/CL43.htm',
 ('PK','Adha',1426):'SBP BPRD CL2/2006: banks closed 10-12 Jan 2006 https://archive.sbp.org.pk/bpd/2006/CL2.htm',
 ('PK','Adha',1427):'SBP BPRD CL31/2006: banks closed 1-2 Jan 2007 https://archive.sbp.org.pk/bprd/2006/CL31.htm',
 ('PK','Adha',1428):'SBP BPRD CL38/2007: banks closed 20-22 Dec 2007 https://www.sbp.org.pk/bprd/2007/CL38.htm',
 ('PK','Adha',1429):'SBP BPRD CL35/2008: banks closed 8-10 Dec 2008 https://www.sbp.org.pk/bprd/2008/CL35.htm',
 ('PK','Adha',1432):'SBP BPRD CL23/2011: banks closed 7-8 Nov 2011 https://www.sbp.org.pk/bprd/2011/CL23.htm',
 ('PK','Fitr',1447):'Cabinet Division holidays 20-21 Mar 2026; SUPARCO expected 21 Mar (Arab News https://www.arabnews.pk/node/2636481)',
 ('BD','Fitr',1430):'FE 2009-09-20: Eid Mon 21 Sep if moon sighted that evening, else Tue 22 Sep https://today.thefinancialexpress.com.bd/print/moon-sighting-committee-meets-this-evening',
}
# sample coverage: BD Jul 2009-Jun 2026 (+Jul 2026); PK Jul 2005-Dec 2024
samples={'BD':(date(2009,7,1),date(2026,7,31)),'PK':(date(2005,7,1),date(2026,9,30))}
out=[]
for c in ['BD','PK']:
  for y in range(1426,1448):
    for ev,(m,d) in [('Fitr',(10,1)),('Adha',(12,10))]:
      uq=Hijri(y,m,d).to_gregorian()
      k=(c,ev,y)
      lo,hi=samples[c]
      # in sample if any day of the 30-day window ending on Eid falls in sample range
      from datetime import timedelta
      insample = (uq+timedelta(days=1) >= lo) and (uq-timedelta(days=30) <= hi)
      if k in src:
        r=src[k]; dt=date.fromisoformat(r['date'])
        status='sourced' if r['source_type'] in ('news','icop_official','icop_observer') else 'sourced_secondary'
        out.append(dict(country=c,event=ev,hijri_year=y,eid_date=dt.isoformat(),status=status,
          umm_al_qura=uq.isoformat(),diff_vs_uq_days=(dt-uq).days,in_sample=int(insample),
          source=r['source'],note=r['note']))
      else:
        out.append(dict(country=c,event=ev,hijri_year=y,eid_date=uq.isoformat(),status='fallback_umm_al_qura',
          umm_al_qura=uq.isoformat(),diff_vs_uq_days=0,in_sample=int(insample),
          source='Umm al-Qura calendar (hijri-converter 2.3)',note=holiday.get(k,'no local announcement found')))
w=csv.DictWriter(open("data/eid_dates.csv",'w',newline=''),fieldnames=list(out[0].keys()))
w.writeheader(); w.writerows(out)
import collections
print(collections.Counter((o['country'],o['status'],o['in_sample']) for o in out))
print('diff distribution (sourced):',collections.Counter((o['country'],o['diff_vs_uq_days']) for o in out if o['status']!='fallback_umm_al_qura'))
for o in out:
  if o['status']=='fallback_umm_al_qura' and o['in_sample']: print('FALLBACK in-sample:',o['country'],o['event'],o['hijri_year'],o['eid_date'])
  if o['status']!='fallback_umm_al_qura' and o['diff_vs_uq_days'] not in (0,1): print('CHECK diff:',o['country'],o['event'],o['eid_date'],o['diff_vs_uq_days'])
