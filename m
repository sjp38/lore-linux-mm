Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 305EB6B0035
	for <linux-mm@kvack.org>; Thu,  9 Jan 2014 15:00:01 -0500 (EST)
Received: by mail-wg0-f41.google.com with SMTP id y10so6352955wgg.0
        for <linux-mm@kvack.org>; Thu, 09 Jan 2014 12:00:00 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id c20si1933155wjs.154.2014.01.09.11.59.59
        for <linux-mm@kvack.org>;
        Thu, 09 Jan 2014 11:59:59 -0800 (PST)
Message-ID: <52CEFF97.6000709@redhat.com>
Date: Thu, 09 Jan 2014 14:59:19 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 4/5] x86: mm: Change tlb_flushall_shift for IvyBridge
References: <1389278098-27154-1-git-send-email-mgorman@suse.de> <1389278098-27154-5-git-send-email-mgorman@suse.de>
In-Reply-To: <1389278098-27154-5-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Alex Shi <alex.shi@linaro.org>, Ingo Molnar <mingo@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, H Peter Anvin <hpa@zytor.com>, Linux-X86 <x86@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 01/09/2014 09:34 AM, Mel Gorman wrote:
> There was a large performance regression that was bisected to commit 611ae8e3
> (x86/tlb: enable tlb flush range support for x86). This patch simply changes
> the default balance point between a local and global flush for IvyBridge.
>
> In the interest of allowing the tests to be reproduced, this patch was
> tested using mmtests 0.15 with the following configurations
>
> 	configs/config-global-dhp__tlbflush-performance
> 	configs/config-global-dhp__scheduler-performance
> 	configs/config-global-dhp__network-performance


> Based on these results, changing the default for Ivybridge seems
> like a logical choice.
>
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> Reviewed-by: Alex Shi <alex.shi@linaro.org>

Reviewed-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
