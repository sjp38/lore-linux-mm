Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f180.google.com (mail-we0-f180.google.com [74.125.82.180])
	by kanga.kvack.org (Postfix) with ESMTP id DC93F6B00A0
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 09:22:12 -0500 (EST)
Received: by mail-we0-f180.google.com with SMTP id t61so3462525wes.39
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 06:22:12 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id i10si4636156wjz.160.2013.12.09.06.22.11
        for <linux-mm@kvack.org>;
        Mon, 09 Dec 2013 06:22:11 -0800 (PST)
Message-ID: <52A5D20F.4010702@redhat.com>
Date: Mon, 09 Dec 2013 09:22:07 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 04/18] mm: numa: Do not clear PMD during PTE update scan
References: <1386572952-1191-1-git-send-email-mgorman@suse.de> <1386572952-1191-5-git-send-email-mgorman@suse.de>
In-Reply-To: <1386572952-1191-5-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Alex Thorlton <athorlton@sgi.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 12/09/2013 02:08 AM, Mel Gorman wrote:
> If the PMD is flushed then a parallel fault in handle_mm_fault() will enter
> the pmd_none and do_huge_pmd_anonymous_page() path where it'll attempt
> to insert a huge zero page. This is wasteful so the patch avoids clearing
> the PMD when setting pmd_numa.
> 
> Cc: stable@vger.kernel.org
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Reviewed-by: Rik van Riel <riel@redhat.com>


-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
