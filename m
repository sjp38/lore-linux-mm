Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f42.google.com (mail-ee0-f42.google.com [74.125.83.42])
	by kanga.kvack.org (Postfix) with ESMTP id 59B306B0035
	for <linux-mm@kvack.org>; Thu,  9 Jan 2014 14:44:35 -0500 (EST)
Received: by mail-ee0-f42.google.com with SMTP id e53so1540916eek.29
        for <linux-mm@kvack.org>; Thu, 09 Jan 2014 11:44:34 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id a9si5361503eew.243.2014.01.09.11.44.33
        for <linux-mm@kvack.org>;
        Thu, 09 Jan 2014 11:44:34 -0800 (PST)
Message-ID: <52CEFBFD.3080800@redhat.com>
Date: Thu, 09 Jan 2014 14:43:57 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/5] x86: mm: Account for TLB flushes only when debugging
References: <1389278098-27154-1-git-send-email-mgorman@suse.de> <1389278098-27154-2-git-send-email-mgorman@suse.de>
In-Reply-To: <1389278098-27154-2-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Alex Shi <alex.shi@linaro.org>, Ingo Molnar <mingo@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Fengguang Wu <fengguang.wu@intel.com>, H Peter Anvin <hpa@zytor.com>, Linux-X86 <x86@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 01/09/2014 09:34 AM, Mel Gorman wrote:
> Bisection between 3.11 and 3.12 fingered commit 9824cf97 (mm: vmstats:
> tlb flush counters).  The counters are undeniably useful but how often
> do we really need to debug TLB flush related issues? It does not justify
> taking the penalty everywhere so make it a debugging option.
>
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Reviewed-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
