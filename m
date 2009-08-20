Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 671756B005D
	for <linux-mm@kvack.org>; Fri, 21 Aug 2009 11:18:16 -0400 (EDT)
Received: from imap1.linux-foundation.org (imap1.linux-foundation.org [140.211.169.55])
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id n7LFIIm4001931
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-mm@kvack.org>; Fri, 21 Aug 2009 08:18:20 -0700
Date: Thu, 20 Aug 2009 16:13:25 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: Scalability fixes -- 2.6.31 candidate?
Message-Id: <20090820161325.562b255e.akpm@linux-foundation.org>
In-Reply-To: <20090820190941.GA29572@balbir.in.ibm.com>
References: <20090820190941.GA29572@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: kamezawa.hiroyu@jp.fujitsu.com, prarit@redhat.com, andi.kleen@intel.com, m-kosaki@ceres.dti.ne.jp, dmiyakawa@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mingo@elte.hu
List-ID: <linux-mm.kvack.org>

On Fri, 21 Aug 2009 00:39:42 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> Hi, Andrew,
> 
> I've been wondering if the scalability fixes for root overhead in
> memory cgroup is a candidate for 2.6.31?

These?

memcg-improve-resource-counter-scalability.patch
memcg-improve-resource-counter-scalability-checkpatch-fixes.patch
memcg-improve-resource-counter-scalability-v5.patch


> They don't change
> functionality but help immensely using existing accounting features.
> 
> Opening up the email for more debate and discussion and thoughts.
> 

They don't apply terribly well to mainline:

patching file mm/memcontrol.c
Hunk #1 FAILED at 70.
Hunk #2 FAILED at 479.
Hunk #3 FAILED at 1295.
Hunk #4 FAILED at 1359.
Hunk #5 FAILED at 1432.
Hunk #6 FAILED at 1514.
Hunk #7 FAILED at 1534.
Hunk #8 FAILED at 1605.
Hunk #9 FAILED at 1798.
Hunk #10 FAILED at 1826.
Hunk #11 FAILED at 1883.
Hunk #12 FAILED at 1981.
Hunk #13 succeeded at 2091 (offset -405 lines).
12 out of 13 hunks FAILED -- saving rejects to file mm/memcontrol.c.rej
Failed to apply memcg-improve-resource-counter-scalability

so maybe you're referring to these:

memcg-remove-the-overhead-associated-with-the-root-cgroup.patch
memcg-remove-the-overhead-associated-with-the-root-cgroup-fix.patch
memcg-remove-the-overhead-associated-with-the-root-cgroup-fix-2.patch

as well.

But then memcg-improve-resource-counter-scalability.patch still doesn't
apply.  Maybe memcg-improve-resource-counter-scalability.patch depends
on memory-controller-soft-limit-*.patch too.  I stopped looking.

It's a lot of material and a lot of churn.  I'd be more inclined to
proceed with a 2.6.32 merge and then perhaps you can see if you can
come up with a minimal patchset for -stable, see if the -stable
maintainers can be talked into merging it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
