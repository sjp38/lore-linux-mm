Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f172.google.com (mail-ea0-f172.google.com [209.85.215.172])
	by kanga.kvack.org (Postfix) with ESMTP id 53E8C6B0037
	for <linux-mm@kvack.org>; Thu, 16 Jan 2014 07:25:28 -0500 (EST)
Received: by mail-ea0-f172.google.com with SMTP id g15so512662eak.31
        for <linux-mm@kvack.org>; Thu, 16 Jan 2014 04:25:23 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id 3si1503588eeq.206.2014.01.16.04.25.22
        for <linux-mm@kvack.org>;
        Thu, 16 Jan 2014 04:25:23 -0800 (PST)
Message-ID: <52D7CFAA.6060903@redhat.com>
Date: Thu, 16 Jan 2014 07:25:14 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: vmstat: Do not display stats for TLB flushes unless
 debugging
References: <1389278098-27154-1-git-send-email-mgorman@suse.de> <1389278098-27154-2-git-send-email-mgorman@suse.de> <20140116111205.GN4963@suse.de>
In-Reply-To: <20140116111205.GN4963@suse.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Alex Shi <alex.shi@linaro.org>, Ingo Molnar <mingo@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, H Peter Anvin <hpa@zytor.com>, Linux-X86 <x86@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 01/16/2014 06:12 AM, Mel Gorman wrote:
> The patch "x86: mm: Account for TLB flushes only when debugging" removed
> vmstat counters related to TLB flushes unless CONFIG_DEBUG_TLBFLUSH was
> set from the vm_event_item enum but not the vmstat_text text.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
