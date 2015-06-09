Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f42.google.com (mail-yh0-f42.google.com [209.85.213.42])
	by kanga.kvack.org (Postfix) with ESMTP id 727716B006E
	for <linux-mm@kvack.org>; Tue,  9 Jun 2015 16:02:53 -0400 (EDT)
Received: by yhak3 with SMTP id k3so11641383yha.2
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 13:02:53 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y28si3110952yhy.53.2015.06.09.13.02.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Jun 2015 13:02:52 -0700 (PDT)
Message-ID: <55774664.6060402@redhat.com>
Date: Tue, 09 Jun 2015 16:02:44 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/4] mm: Defer flush of writable TLB entries
References: <1433871118-15207-1-git-send-email-mgorman@suse.de> <1433871118-15207-4-git-send-email-mgorman@suse.de>
In-Reply-To: <1433871118-15207-4-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, H Peter Anvin <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 06/09/2015 01:31 PM, Mel Gorman wrote:
> If a PTE is unmapped and it's dirty then it was writable recently. Due
> to deferred TLB flushing, it's best to assume a writable TLB cache entry
> exists. With that assumption, the TLB must be flushed before any IO can
> start or the page is freed to avoid lost writes or data corruption. This
> patch defers flushing of potentially writable TLBs as long as possible.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
