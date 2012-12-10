Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id 160746B0068
	for <linux-mm@kvack.org>; Mon, 10 Dec 2012 14:23:42 -0500 (EST)
Received: by mail-bk0-f41.google.com with SMTP id jg9so1538871bkc.14
        for <linux-mm@kvack.org>; Mon, 10 Dec 2012 11:23:40 -0800 (PST)
Date: Mon, 10 Dec 2012 20:23:32 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 00/49] Automatic NUMA Balancing v10
Message-ID: <20121210192332.GC14412@gmail.com>
References: <1354875832-9700-1-git-send-email-mgorman@suse.de>
 <20121210164225.GC6348@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121210164225.GC6348@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Mel Gorman <mgorman@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Hillf Danton <dhillf@gmail.com>, David Rientjes <rientjes@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Alex Shi <lkml.alex@gmail.com>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>


* Srikar Dronamraju <srikar@linux.vnet.ibm.com> wrote:

> KernelVersion: 3.7.0-rc8-tip_master+(December 7th Snapshot)

> Please do let me know if you have questions/suggestions.

Do you still have the exact sha1 by any chance?

By the date of the snapshot I'd say that this fix:

  f0c77b62ba9d sched: Fix NUMA_EXCLUDE_AFFINE check

could improve performance on your box.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
