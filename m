Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id AAEB96B00CC
	for <linux-mm@kvack.org>; Fri, 30 Nov 2012 11:09:34 -0500 (EST)
Message-ID: <50B8DA2D.8030604@redhat.com>
Date: Fri, 30 Nov 2012 11:09:17 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: Results for balancenuma v8, autonuma-v28fast and numacore-20121126
References: <1353612353-1576-1-git-send-email-mgorman@suse.de> <20121126145800.GK8218@suse.de> <20121128134930.GB20087@suse.de> <20121130113300.GC20087@suse.de> <20121130114145.GD20087@suse.de>
In-Reply-To: <20121130114145.GD20087@suse.de>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Hillf Danton <dhillf@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Alex Shi <lkml.alex@gmail.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 11/30/2012 06:41 AM, Mel Gorman wrote:
> This is an another insanely long mail. Short summary, based on the results
> of what is in tip/master right now, I think if we're going to merge
> anything for v3.8 it should be the "Automatic NUMA Balancing V8". It does
> reasonably well for many of the workloads and AFAIK there is no reason why
> numacore or autonuma could not be rebased on top with the view to merging
> proper scheduling and placement policies in 3.9.

Given how minimalistic balancenuma is, and how there does not seem
to be anything significant in the way of performance regressions
with balancenuma, I have no objections to Linus merging all of
balancenuma for 3.8.

That could significantly reduce the amount of NUMA code we need
to "fight over" for the 3.9 kernel :)

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
