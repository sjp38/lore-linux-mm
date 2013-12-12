Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f48.google.com (mail-yh0-f48.google.com [209.85.213.48])
	by kanga.kvack.org (Postfix) with ESMTP id A54876B0038
	for <linux-mm@kvack.org>; Thu, 12 Dec 2013 01:50:13 -0500 (EST)
Received: by mail-yh0-f48.google.com with SMTP id f73so6031654yha.35
        for <linux-mm@kvack.org>; Wed, 11 Dec 2013 22:50:13 -0800 (PST)
Received: from mail-yh0-x233.google.com (mail-yh0-x233.google.com [2607:f8b0:4002:c01::233])
        by mx.google.com with ESMTPS id 25si20770963yhc.107.2013.12.11.22.50.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 11 Dec 2013 22:50:12 -0800 (PST)
Received: by mail-yh0-f51.google.com with SMTP id c41so5945437yho.24
        for <linux-mm@kvack.org>; Wed, 11 Dec 2013 22:50:12 -0800 (PST)
Date: Wed, 11 Dec 2013 22:50:09 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v7 4/4] sched/numa: fix period_slot recalculation
In-Reply-To: <1386807143-15994-5-git-send-email-liwanp@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.02.1312112249570.11740@chino.kir.corp.google.com>
References: <1386807143-15994-1-git-send-email-liwanp@linux.vnet.ibm.com> <1386807143-15994-5-git-send-email-liwanp@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 12 Dec 2013, Wanpeng Li wrote:

> Changelog:
>  v3 -> v4:
>   * remove period_slot recalculation
> 
> The original code is as intended and was meant to scale the difference
> between the NUMA_PERIOD_THRESHOLD and local/remote ratio when adjusting
> the scan period. The period_slot recalculation can be dropped.
> 
> Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Acked-by: Mel Gorman <mgorman@suse.de>
> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
