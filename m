Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id EC8A15F0040
	for <linux-mm@kvack.org>; Tue, 19 Oct 2010 20:23:13 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9K0NBwG004408
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 20 Oct 2010 09:23:11 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id EFF9D45DE4F
	for <linux-mm@kvack.org>; Wed, 20 Oct 2010 09:23:10 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id CEFAA45DE4E
	for <linux-mm@kvack.org>; Wed, 20 Oct 2010 09:23:10 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id B9DCD1DB8038
	for <linux-mm@kvack.org>; Wed, 20 Oct 2010 09:23:10 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 771121DB803C
	for <linux-mm@kvack.org>; Wed, 20 Oct 2010 09:23:10 +0900 (JST)
Date: Wed, 20 Oct 2010 09:17:46 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH V2] nommu: add anonymous page memcg accounting
Message-Id: <20101020091746.f0cc5dc2.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1287512657.2500.31.camel@iscandar.digidescorp.com>
References: <1287491654-4005-1-git-send-email-steve@digidescorp.com>
	<20101019154819.GC15844@balbir.in.ibm.com>
	<1287512657.2500.31.camel@iscandar.digidescorp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: steve@digidescorp.com
Cc: balbir@linux.vnet.ibm.com, linux-mm@kvack.org, dhowells@redhat.com, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 19 Oct 2010 13:24:17 -0500
"Steven J. Magnani" <steve@digidescorp.com> wrote:

> On Tue, 2010-10-19 at 21:18 +0530, Balbir Singh wrote:
> > * Steven J. Magnani <steve@digidescorp.com> [2010-10-19 07:34:14]:
> > 
> > > Add the necessary calls to track VM anonymous page usage (only).
> > > 
> > > V2 changes:
> > > * Added update of memory cgroup documentation
> > > * Clarify use of 'file' to distinguish anonymous mappings
> > > 
> > > Signed-off-by: Steven J. Magnani <steve@digidescorp.com>
> > > ---
> > > diff -uprN a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
> > > --- a/Documentation/cgroups/memory.txt	2010-10-05 09:14:36.000000000 -0500
> > > +++ b/Documentation/cgroups/memory.txt	2010-10-19 07:28:04.000000000 -0500
> > > @@ -34,6 +34,7 @@ Current Status: linux-2.6.34-mmotm(devel
> > > 
> > >  Features:
> > >   - accounting anonymous pages, file caches, swap caches usage and limiting them.
> > > +   NOTE: On NOMMU systems, only anonymous pages are accounted.
> > >   - private LRU and reclaim routine. (system's global LRU and private LRU
> > >     work independently from each other)
> > >   - optionally, memory+swap usage can be accounted and limited.
> > > @@ -640,7 +641,30 @@ At reading, current status of OOM is sho
> > >  	under_oom	 0 or 1 (if 1, the memory cgroup is under OOM, tasks may
> > >  				 be stopped.)
> > > 
> > > -11. TODO
> > > +11. NOMMU Support
> <snip>
> > > +
> > > +At the present time, only anonymous pages are included in NOMMU memory cgroup
> > > +accounting.
> > 
> > What is the reason for tracking just anonymous memory?
> 
> Tracking more than that is beyond my current scope, and perhaps of
> limited benefit under an assumption that NOMMU systems don't usually
> work with large files. The limitations of the implementation are
> documented, so hopefully anyone who needs more functionality will know
> that they need to implement it.
> 

What happens at reaching limit ? memory can be reclaimed ?

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
