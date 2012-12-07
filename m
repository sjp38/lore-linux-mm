Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 4FFD36B0098
	for <linux-mm@kvack.org>; Fri,  7 Dec 2012 06:01:19 -0500 (EST)
Received: by mail-ea0-f169.google.com with SMTP id a12so164053eaa.14
        for <linux-mm@kvack.org>; Fri, 07 Dec 2012 03:01:17 -0800 (PST)
Date: Fri, 7 Dec 2012 12:01:13 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 00/49] Automatic NUMA Balancing v10
Message-ID: <20121207110113.GB21482@gmail.com>
References: <1354875832-9700-1-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1354875832-9700-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Hillf Danton <dhillf@gmail.com>, David Rientjes <rientjes@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Alex Shi <lkml.alex@gmail.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>


* Mel Gorman <mgorman@suse.de> wrote:

> This is a full release of all the patches so apologies for the 
> flood. [...]

I have yet to process all your mails, but assuming I address all 
your review feedback and the latest unified tree in tip:master 
shows no regression in your testing, would you be willing to 
start using it for ongoing work?

It would make it much easier for me to pick up your 
enhancements, fixes, etc.

> Changelog since V9
>   o Migration scalability                                             (mingo)

To *really* see migration scalability bottlenecks you need to 
remove the migration-bandwidth throttling kludge from your tree 
(or configure it up very high if you want to do it simple).

Some (certainly not all) of the performance regressions you 
reported were certainly due to numa/core code hitting the 
migration codepaths as aggressively as the workload demanded - 
and hitting scalability bottlenecks.

The right approach is to hit scalability bottlenecks and fix 
them.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
