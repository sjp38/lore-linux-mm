Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f172.google.com (mail-qc0-f172.google.com [209.85.216.172])
	by kanga.kvack.org (Postfix) with ESMTP id 999F66B0031
	for <linux-mm@kvack.org>; Fri, 13 Dec 2013 13:09:49 -0500 (EST)
Received: by mail-qc0-f172.google.com with SMTP id e16so1752347qcx.17
        for <linux-mm@kvack.org>; Fri, 13 Dec 2013 10:09:49 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id r6si2986795qaj.79.2013.12.13.10.09.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Dec 2013 10:09:47 -0800 (PST)
Date: Fri, 13 Dec 2013 19:09:33 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v8 1/4] sched/numa: drop
 sysctl_numa_balancing_settle_count sysctl
Message-ID: <20131213180933.GS21999@twins.programming.kicks-ass.net>
References: <1386833006-6600-1-git-send-email-liwanp@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1386833006-6600-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Dec 12, 2013 at 03:23:23PM +0800, Wanpeng Li wrote:
> Changelog:
>  v7 -> v8:
>   * remove references to it in Documentation/sysctl/kernel.txt 

Please do not put such bits in the changelog proper, but put them below
the --- line, that way they disappear automagically.

Applied all 4, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
