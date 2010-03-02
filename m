Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 491E06B0078
	for <linux-mm@kvack.org>; Tue,  2 Mar 2010 10:26:11 -0500 (EST)
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.31.245])
	by e23smtp01.au.ibm.com (8.14.3/8.13.1) with ESMTP id o22FO3aM022882
	for <linux-mm@kvack.org>; Wed, 3 Mar 2010 02:24:03 +1100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o22FQ5JL1880304
	for <linux-mm@kvack.org>; Wed, 3 Mar 2010 02:26:05 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o22FQ4rN005861
	for <linux-mm@kvack.org>; Wed, 3 Mar 2010 02:26:05 +1100
Date: Tue, 2 Mar 2010 20:56:00 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH -mmotm 3/3] memcg: dirty pages instrumentation
Message-ID: <20100302152600.GA16532@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <1267478620-5276-1-git-send-email-arighi@develer.com>
 <1267478620-5276-4-git-send-email-arighi@develer.com>
 <1267537736.25158.54.camel@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1267537736.25158.54.camel@laptop>
Sender: owner-linux-mm@kvack.org
To: Peter Zijlstra <peterz@infradead.org>
Cc: Andrea Righi <arighi@develer.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Suleiman Souhlal <suleiman@google.com>, Greg Thelen <gthelen@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Trond Myklebust <trond.myklebust@fys.uio.no>
List-ID: <linux-mm.kvack.org>

* Peter Zijlstra <peterz@infradead.org> [2010-03-02 14:48:56]:

> This is ugly and broken.. I thought you'd agreed to something like:
> 
>  if (mem_cgroup_has_dirty_limit(cgroup))
>    use mem_cgroup numbers
>  else
>    use global numbers
> 
> That allows for a 0 dirty limit (which should work and basically makes
> all io synchronous).
> 
> Also, I'd put each of those in a separate function, like:
> 
> unsigned long reclaimable_pages(cgroup)
> {
>   if (mem_cgroup_has_dirty_limit(cgroup))
>     return mem_cgroup_page_stat(MEMCG_NR_RECLAIM_PAGES);
>   
>   return global_page_state(NR_FILE_DIRTY) + global_page_state(NR_NFS_UNSTABLE);
> }
>

I agree, I should have been more specific about the naming convention,
this is what I meant - along these lines as we do with
zone_nr_lru_pages(), etc.
 
> Which raises another question, you should probably rebase on top of
> Trond's patches, which removes BDI_RECLAIMABLE, suggesting you also
> loose MEMCG_NR_RECLAIM_PAGES in favour of the DIRTY+UNSTABLE split.
> 

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
