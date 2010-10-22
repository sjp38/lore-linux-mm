Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 6A09A6B0071
	for <linux-mm@kvack.org>; Fri, 22 Oct 2010 14:45:55 -0400 (EDT)
Date: Fri, 22 Oct 2010 19:45:39 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: zone state overhead
Message-ID: <20101022184539.GG2160@csn.ul.ie>
References: <20101014120804.8B8F.A69D9226@jp.fujitsu.com> <20101018103941.GX30667@csn.ul.ie> <20101019100658.A1B3.A69D9226@jp.fujitsu.com> <20101019090803.GF30667@csn.ul.ie> <20101022141223.GF2160@csn.ul.ie> <alpine.DEB.2.00.1010221015001.20437@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1010221015001.20437@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Fri, Oct 22, 2010 at 10:23:34AM -0500, Christoph Lameter wrote:
> On Fri, 22 Oct 2010, Mel Gorman wrote:
> 
> > index eaaea37..c67d333 100644
> > --- a/include/linux/vmstat.h
> > +++ b/include/linux/vmstat.h
> > @@ -254,6 +254,8 @@ extern void dec_zone_state(struct zone *, enum zone_stat_item);
> >  extern void __dec_zone_state(struct zone *, enum zone_stat_item);
> >
> >  void refresh_cpu_vm_stats(int);
> > +void disable_pgdat_percpu_threshold(pg_data_t *pgdat);
> > +void enable_pgdat_percpu_threshold(pg_data_t *pgdat);
> >  #else /* CONFIG_SMP */
> 
> The naming is a bit misleading since disabling may only mean reducing the
> treshold.
> 

Suggestions? shrink, reduce?

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
