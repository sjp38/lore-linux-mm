Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qe0-f52.google.com (mail-qe0-f52.google.com [209.85.128.52])
	by kanga.kvack.org (Postfix) with ESMTP id DC6EF6B0035
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 05:24:23 -0500 (EST)
Received: by mail-qe0-f52.google.com with SMTP id ne12so5094671qeb.25
        for <linux-mm@kvack.org>; Wed, 11 Dec 2013 02:24:23 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id nh12si15105477qeb.4.2013.12.11.02.24.18
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Dec 2013 02:24:18 -0800 (PST)
Date: Wed, 11 Dec 2013 11:24:08 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v6 0/6] mm: sched: numa: several fixups
Message-ID: <20131211102408.GI13532@twins.programming.kicks-ass.net>
References: <1386756961-3887-1-git-send-email-liwanp@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1386756961-3887-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Dec 11, 2013 at 06:15:55PM +0800, Wanpeng Li wrote:
> Hi Andrew,

You'll find kernel/sched/ has a maintainer !Andrew.

>  include/linux/sched/sysctl.h |    1 -
>  kernel/sched/debug.c         |    2 +-
>  kernel/sched/fair.c          |   17 ++++-------------
>  kernel/sysctl.c              |    7 -------
>  mm/migrate.c                 |    4 ----
>  5 files changed, 5 insertions(+), 26 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
