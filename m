Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f47.google.com (mail-yh0-f47.google.com [209.85.213.47])
	by kanga.kvack.org (Postfix) with ESMTP id E8F166B0031
	for <linux-mm@kvack.org>; Thu, 12 Dec 2013 01:41:51 -0500 (EST)
Received: by mail-yh0-f47.google.com with SMTP id 29so6000541yhl.34
        for <linux-mm@kvack.org>; Wed, 11 Dec 2013 22:41:51 -0800 (PST)
Received: from mail-yh0-x234.google.com (mail-yh0-x234.google.com [2607:f8b0:4002:c01::234])
        by mx.google.com with ESMTPS id t39si15596040yhp.25.2013.12.11.22.41.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 11 Dec 2013 22:41:50 -0800 (PST)
Received: by mail-yh0-f52.google.com with SMTP id i7so861950yha.39
        for <linux-mm@kvack.org>; Wed, 11 Dec 2013 22:41:50 -0800 (PST)
Date: Wed, 11 Dec 2013 22:41:47 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v7 1/4] sched/numa: drop sysctl_numa_balancing_settle_count
 sysctl
In-Reply-To: <1386807143-15994-2-git-send-email-liwanp@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.02.1312112241080.11740@chino.kir.corp.google.com>
References: <1386807143-15994-1-git-send-email-liwanp@linux.vnet.ibm.com> <1386807143-15994-2-git-send-email-liwanp@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 12 Dec 2013, Wanpeng Li wrote:

> commit 887c290e (sched/numa: Decide whether to favour task or group weights
> based on swap candidate relationships) drop the check against
> sysctl_numa_balancing_settle_count, this patch remove the sysctl.
> 

What about the references to it in Documentation/sysctl/kernel.txt?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
