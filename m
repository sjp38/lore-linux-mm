Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f169.google.com (mail-ea0-f169.google.com [209.85.215.169])
	by kanga.kvack.org (Postfix) with ESMTP id 276576B0035
	for <linux-mm@kvack.org>; Thu,  9 Jan 2014 14:47:39 -0500 (EST)
Received: by mail-ea0-f169.google.com with SMTP id l9so1400545eaj.14
        for <linux-mm@kvack.org>; Thu, 09 Jan 2014 11:47:38 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id l44si5409584eem.145.2014.01.09.11.47.37
        for <linux-mm@kvack.org>;
        Thu, 09 Jan 2014 11:47:38 -0800 (PST)
Message-ID: <52CEFCB9.2030604@redhat.com>
Date: Thu, 09 Jan 2014 14:47:05 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/5] x86: mm: Clean up inconsistencies when flushing TLB
 ranges
References: <1389278098-27154-1-git-send-email-mgorman@suse.de> <1389278098-27154-3-git-send-email-mgorman@suse.de>
In-Reply-To: <1389278098-27154-3-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Alex Shi <alex.shi@linaro.org>, Ingo Molnar <mingo@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, H Peter Anvin <hpa@zytor.com>, Linux-X86 <x86@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 01/09/2014 09:34 AM, Mel Gorman wrote:
> NR_TLB_LOCAL_FLUSH_ALL is not always accounted for correctly and the
> comparison with total_vm is done before taking tlb_flushall_shift into
> account. Clean it up.
>
> Signed-off-by: Mel Gorman <mgorman@suse.de>
> Reviewed-by: Alex Shi <alex.shi@linaro.org>

Reviewed-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
