Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 559F26B0088
	for <linux-mm@kvack.org>; Fri, 21 Aug 2009 11:22:39 -0400 (EDT)
Received: from d23relay01.au.ibm.com (d23relay01.au.ibm.com [202.81.31.243])
	by e23smtp03.au.ibm.com (8.14.3/8.13.1) with ESMTP id n7LFKLHv014430
	for <linux-mm@kvack.org>; Sat, 22 Aug 2009 01:20:21 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay01.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n7L5T9pO528636
	for <linux-mm@kvack.org>; Fri, 21 Aug 2009 15:31:59 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n7L5T8DJ031929
	for <linux-mm@kvack.org>; Fri, 21 Aug 2009 15:29:09 +1000
Date: Fri, 21 Aug 2009 10:58:58 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: Scalability fixes -- 2.6.31 candidate?
Message-ID: <20090821052858.GB29572@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090820190941.GA29572@balbir.in.ibm.com> <20090820161325.562b255e.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090820161325.562b255e.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kamezawa.hiroyu@jp.fujitsu.com, prarit@redhat.com, andi.kleen@intel.com, m-kosaki@ceres.dti.ne.jp, dmiyakawa@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mingo@elte.hu
List-ID: <linux-mm.kvack.org>

* Andrew Morton <akpm@linux-foundation.org> [2009-08-20 16:13:25]:

> On Fri, 21 Aug 2009 00:39:42 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
> > Hi, Andrew,
> > 
> > I've been wondering if the scalability fixes for root overhead in
> > memory cgroup is a candidate for 2.6.31?
> 
> These?
> 
> memcg-improve-resource-counter-scalability.patch
> memcg-improve-resource-counter-scalability-checkpatch-fixes.patch
> memcg-improve-resource-counter-scalability-v5.patch
> 
> 
> > They don't change
> > functionality but help immensely using existing accounting features.
> > 
> > Opening up the email for more debate and discussion and thoughts.
> > 
> 
> They don't apply terribly well to mainline:
> 
> patching file mm/memcontrol.c
> Hunk #1 FAILED at 70.
> Hunk #2 FAILED at 479.
> Hunk #3 FAILED at 1295.
> Hunk #4 FAILED at 1359.
> Hunk #5 FAILED at 1432.
> Hunk #6 FAILED at 1514.
> Hunk #7 FAILED at 1534.
> Hunk #8 FAILED at 1605.
> Hunk #9 FAILED at 1798.
> Hunk #10 FAILED at 1826.
> Hunk #11 FAILED at 1883.
> Hunk #12 FAILED at 1981.
> Hunk #13 succeeded at 2091 (offset -405 lines).
> 12 out of 13 hunks FAILED -- saving rejects to file mm/memcontrol.c.rej
> Failed to apply memcg-improve-resource-counter-scalability
> 
> so maybe you're referring to these:
> 
> memcg-remove-the-overhead-associated-with-the-root-cgroup.patch
> memcg-remove-the-overhead-associated-with-the-root-cgroup-fix.patch
> memcg-remove-the-overhead-associated-with-the-root-cgroup-fix-2.patch
> 
> as well.
>

Yes, I was referring to those
 
> But then memcg-improve-resource-counter-scalability.patch still doesn't
> apply.  Maybe memcg-improve-resource-counter-scalability.patch depends
> on memory-controller-soft-limit-*.patch too.  I stopped looking.
> 

Yes, there is some diffs that get picked up due to the soft_limit
feature.


> It's a lot of material and a lot of churn.  I'd be more inclined to
> proceed with a 2.6.32 merge and then perhaps you can see if you can
> come up with a minimal patchset for -stable, see if the -stable
> maintainers can be talked into merging it.
> 

Fair enough.. I do have a backport to 2.6.31-rc5 mainline, but going
the stable route would also work.

Thanks!


-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
