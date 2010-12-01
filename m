Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id B71B06B004A
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 00:21:53 -0500 (EST)
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by e28smtp04.in.ibm.com (8.14.4/8.13.1) with ESMTP id oB15LmfV026461
	for <linux-mm@kvack.org>; Wed, 1 Dec 2010 10:51:48 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id oB15Ll6r3526672
	for <linux-mm@kvack.org>; Wed, 1 Dec 2010 10:51:47 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id oB15Llgo019369
	for <linux-mm@kvack.org>; Wed, 1 Dec 2010 10:51:47 +0530
Date: Wed, 1 Dec 2010 10:51:41 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/3] Move zone_reclaim() outside of CONFIG_NUMA
Message-ID: <20101201052141.GJ2746@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20101130101126.17475.18729.stgit@localhost6.localdomain6>
 <20101130101506.17475.34536.stgit@localhost6.localdomain6>
 <20101130142338.5e845880.akpm@linux-foundation.org>
 <20101201043408.GE2746@balbir.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20101201043408.GE2746@balbir.in.ibm.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Christoph Lameter <cl@linux.com>, linux-kernel@vger.kernel.org, kvm <kvm@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

* Balbir Singh <balbir@linux.vnet.ibm.com> [2010-12-01 10:04:08]:

> * Andrew Morton <akpm@linux-foundation.org> [2010-11-30 14:23:38]:
> 
> > On Tue, 30 Nov 2010 15:45:12 +0530
> > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > 
> > > This patch moves zone_reclaim and associated helpers
> > > outside CONFIG_NUMA. This infrastructure is reused
> > > in the patches for page cache control that follow.
> > > 
> > 
> > Thereby adding a nice dollop of bloat to everyone's kernel.  I don't
> > think that is justifiable given that the audience for this feature is
> > about eight people :(
> > 
> > How's about CONFIG_UNMAPPED_PAGECACHE_CONTROL?
> >
> 
> OK, I'll add the config, but this code is enabled under CONFIG_NUMA
> today, so the bloat I agree is more for non NUMA users. I'll make
> CONFIG_UNMAPPED_PAGECACHE_CONTROL default if CONFIG_NUMA is set.
>  
> > Also this patch instantiates sysctl_min_unmapped_ratio and
> > sysctl_min_slab_ratio on non-NUMA builds but fails to make those
> > tunables actually tunable in procfs.  Changes to sysctl.c are
> > needed.
> > 
> 
> Oh! yeah.. I missed it while refactoring, my fault.
> 
> > > Reviewed-by: Christoph Lameter <cl@linux.com>
> > 

My local MTA failed to deliver the message, trying again.

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
