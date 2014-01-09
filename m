Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f51.google.com (mail-ee0-f51.google.com [74.125.83.51])
	by kanga.kvack.org (Postfix) with ESMTP id 62F1A6B0035
	for <linux-mm@kvack.org>; Thu,  9 Jan 2014 15:01:23 -0500 (EST)
Received: by mail-ee0-f51.google.com with SMTP id b15so1540770eek.24
        for <linux-mm@kvack.org>; Thu, 09 Jan 2014 12:01:22 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id n47si5486197eef.94.2014.01.09.12.01.22
        for <linux-mm@kvack.org>;
        Thu, 09 Jan 2014 12:01:22 -0800 (PST)
Message-ID: <52CEFFF3.9010709@redhat.com>
Date: Thu, 09 Jan 2014 15:00:51 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 5/5] mm: x86: Revisit tlb_flushall_shift tuning for page
 flushes except on IvyBridge
References: <1389278098-27154-1-git-send-email-mgorman@suse.de> <1389278098-27154-6-git-send-email-mgorman@suse.de>
In-Reply-To: <1389278098-27154-6-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Alex Shi <alex.shi@linaro.org>, Ingo Molnar <mingo@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, H Peter Anvin <hpa@zytor.com>, Linux-X86 <x86@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 01/09/2014 09:34 AM, Mel Gorman wrote:
> There was a large ebizzy performance regression that was bisected to commit
> 611ae8e3 (x86/tlb: enable tlb flush range support for x86). The problem
> was related to the tlb_flushall_shift tuning for IvyBridge which was
> altered. The problem is that it is not clear if the tuning values for each
> CPU family is correct as the methodology used to tune the values is unclear.
>
> This patch uses a conservative tlb_flushall_shift value for all CPU families
> except IvyBridge so the decision can be revisited if any regression is found
> as a result of this change. IvyBridge is an exception as testing with one
> methodology determined that the value of 2 is acceptable. Details are in the
> changelog for the patch "x86: mm: Change tlb_flushall_shift for IvyBridge".
>
> One important aspect of this to watch out for is Xen. The original commit
> log mentioned large performance gains on Xen. It's possible Xen is more
> sensitive to this value if it flushes small ranges of pages more frequently
> than workloads on bare metal typically do.
>
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Reviewed-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
