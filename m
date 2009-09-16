Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id EDF5C6B004F
	for <linux-mm@kvack.org>; Wed, 16 Sep 2009 03:55:07 -0400 (EDT)
Date: Wed, 16 Sep 2009 16:51:29 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: memcg merge for 2.6.32 (was Re: 2.6.32 -mm merge plans)
Message-Id: <20090916165129.a75879ae.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20090916073727.GP4846@balbir.in.ibm.com>
References: <20090915161535.db0a6904.akpm@linux-foundation.org>
	<20090916073727.GP4846@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, balbir@linux.vnet.ibm.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Wed, 16 Sep 2009 13:07:27 +0530, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> * Andrew Morton <akpm@linux-foundation.org> [2009-09-15 16:15:35]:
> 
> > 
> > memcg-remove-the-overhead-associated-with-the-root-cgroup.patch
> > memcg-remove-the-overhead-associated-with-the-root-cgroup-fix.patch
> > memcg-remove-the-overhead-associated-with-the-root-cgroup-fix-2.patch
> > #memcg-add-comments-explaining-memory-barriers.patch: needs update (Balbir)
> > memcg-add-comments-explaining-memory-barriers.patch
> > memcg-add-comments-explaining-memory-barriers-checkpatch-fixes.patch
> > memory-controller-soft-limit-documentation-v9.patch
> > memory-controller-soft-limit-interface-v9.patch
> > memory-controller-soft-limit-organize-cgroups-v9.patch
> > memory-controller-soft-limit-organize-cgroups-v9-fix.patch
> > memory-controller-soft-limit-refactor-reclaim-flags-v9.patch
> > memory-controller-soft-limit-reclaim-on-contention-v9.patch
> > memory-controller-soft-limit-reclaim-on-contention-v9-fix.patch
> > memory-controller-soft-limit-reclaim-on-contention-v9-fix-softlimit-css-refcnt-handling.patch
> > memory-controller-soft-limit-reclaim-on-contention-v9-fix-softlimit-css-refcnt-handling-fix.patch
> > memcg-improve-resource-counter-scalability.patch
> > memcg-improve-resource-counter-scalability-checkpatch-fixes.patch
> > memcg-improve-resource-counter-scalability-v5.patch
> > memcg-show-swap-usage-in-stat-file.patch
> > memcg-show-swap-usage-in-stat-file-fix.patch
> > 
> >   Merge after checking with Balbir
> 
> 
> I think these are ready for merging, I'll let Kame and Daisuke comment
> on it more. The resource counter scalability patch is the most
> important patch in the series.
> 
I don't have any objection for merging these patches.


Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
