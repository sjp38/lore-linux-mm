Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 209266B0149
	for <linux-mm@kvack.org>; Fri, 29 Oct 2010 17:30:09 -0400 (EDT)
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate3.de.ibm.com (8.13.1/8.13.1) with ESMTP id o9TLU517011129
	for <linux-mm@kvack.org>; Fri, 29 Oct 2010 21:30:05 GMT
Received: from d12av04.megacenter.de.ibm.com (d12av04.megacenter.de.ibm.com [9.149.165.229])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o9TLU6TE4091988
	for <linux-mm@kvack.org>; Fri, 29 Oct 2010 23:30:06 +0200
Received: from d12av04.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av04.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id o9TLU4nr016991
	for <linux-mm@kvack.org>; Fri, 29 Oct 2010 23:30:05 +0200
Date: Fri, 29 Oct 2010 23:30:04 +0200
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: oom killer question
Message-ID: <20101029213004.GA2315@osiris.boeblingen.de.ibm.com>
References: <20101029121456.GA6896@osiris.boeblingen.de.ibm.com>
 <1288376008.13539.8991.camel@nimitz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1288376008.13539.8991.camel@nimitz>
Sender: owner-linux-mm@kvack.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Hartmut Beinlich <HBEINLIC@de.ibm.com>
List-ID: <linux-mm.kvack.org>

On Fri, Oct 29, 2010 at 11:13:28AM -0700, Dave Hansen wrote:
> On Fri, 2010-10-29 at 14:14 +0200, Heiko Carstens wrote:
> > present:2068480kB
> 
> So, ~2GB available.
> 
> >  mlocked:4452kB
> >  unevictable:4452kB writeback:0kB mapped:3684kB shmem:0kB 
> > slab_reclaimable:1778388kB
> > slab_unreclaimable:188388kB kernel_stack:4016kB pagetables:2232kB
> > unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:542
> > all_unreclaimable? yes
> 
> Plus about 1.8GB of unreclaimable slab.  all_unreclaimable is set.  So,
> you reclaimed all of the user memory that you could get and swapped out
> what could have been swapped out.  What was left was slab.
> 
> This OOM looks proper to me.  What was eating all of your slab?

Thanks to you and Andrew for looking at this. I'll ask Hartmut to rerun
the test and taking slabinfo snapshots while doing that.

One question remains however: why is the verbose output saying

slab_reclaimable:1778388kB

and just afterwards

slab_unreclaimable:188388kB

Looking only at slab_reclaimable I had the impression there _could_
have been plenty of memory that could be reclaimed. Just wondering :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
