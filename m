Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id A14AE6B0047
	for <linux-mm@kvack.org>; Thu, 28 Jan 2010 05:34:25 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o0SAYNA9010490
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 28 Jan 2010 19:34:23 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id DCEDF45DE4F
	for <linux-mm@kvack.org>; Thu, 28 Jan 2010 19:34:22 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id B037945DE4E
	for <linux-mm@kvack.org>; Thu, 28 Jan 2010 19:34:22 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9BA521DB803C
	for <linux-mm@kvack.org>; Thu, 28 Jan 2010 19:34:22 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 53B291DB8037
	for <linux-mm@kvack.org>; Thu, 28 Jan 2010 19:34:22 +0900 (JST)
Date: Thu, 28 Jan 2010 19:30:57 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v4 1/2] sysctl clean up vm related variable declarations
Message-Id: <20100128193057.41523885.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.1001280048110.15953@chino.kir.corp.google.com>
References: <20100121145905.84a362bb.kamezawa.hiroyu@jp.fujitsu.com>
	<20100122152332.750f50d9.kamezawa.hiroyu@jp.fujitsu.com>
	<20100125151503.49060e74.kamezawa.hiroyu@jp.fujitsu.com>
	<20100126151202.75bd9347.akpm@linux-foundation.org>
	<20100127085355.f5306e78.kamezawa.hiroyu@jp.fujitsu.com>
	<20100126161952.ee267d1c.akpm@linux-foundation.org>
	<20100127095812.d7493a8f.kamezawa.hiroyu@jp.fujitsu.com>
	<20100127153053.b8a8a1a1.kamezawa.hiroyu@jp.fujitsu.com>
	<20100127153232.f8efc531.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.2.00.1001280048110.15953@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, minchan.kim@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 28 Jan 2010 00:54:49 -0800 (PST)
David Rientjes <rientjes@google.com> wrote:

> > ---
> >  include/linux/mm.h     |    5 +++++
> >  include/linux/mmzone.h |    1 +
> >  include/linux/oom.h    |    5 +++++
> >  kernel/sysctl.c        |   16 ++--------------
> >  mm/mmap.c              |    5 +++++
> >  5 files changed, 18 insertions(+), 14 deletions(-)
> > 
> > Index: mmotm-2.6.33-Jan15-2/include/linux/mm.h
> > ===================================================================
> > --- mmotm-2.6.33-Jan15-2.orig/include/linux/mm.h
> > +++ mmotm-2.6.33-Jan15-2/include/linux/mm.h
> > @@ -1432,6 +1432,7 @@ int in_gate_area_no_task(unsigned long a
> >  #define in_gate_area(task, addr) ({(void)task; in_gate_area_no_task(addr);})
> >  #endif	/* __HAVE_ARCH_GATE_AREA */
> >  
> > +extern int sysctl_drop_caches;
> >  int drop_caches_sysctl_handler(struct ctl_table *, int,
> >  					void __user *, size_t *, loff_t *);
> >  unsigned long shrink_slab(unsigned long scanned, gfp_t gfp_mask,
> > @@ -1476,5 +1477,9 @@ extern int soft_offline_page(struct page
> >  
> >  extern void dump_page(struct page *page);
> >  
> > +#ifndef CONFIG_NOMMU
> > +extern int sysctl_nr_trim_pages;
> 
> This should be #ifndef CONFIG_MMU.
> 
yes...thank you for review.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
