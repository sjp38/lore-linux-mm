Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f52.google.com (mail-ee0-f52.google.com [74.125.83.52])
	by kanga.kvack.org (Postfix) with ESMTP id C73E96B00A4
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 09:34:49 -0500 (EST)
Received: by mail-ee0-f52.google.com with SMTP id d17so1584946eek.25
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 06:34:49 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id m49si9746274eeg.157.2013.12.09.06.34.48
        for <linux-mm@kvack.org>;
        Mon, 09 Dec 2013 06:34:48 -0800 (PST)
Message-ID: <52A5D502.1080404@redhat.com>
Date: Mon, 09 Dec 2013 09:34:42 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 06/18] mm: numa: Ensure anon_vma is locked to prevent
 parallel THP splits
References: <1386572952-1191-1-git-send-email-mgorman@suse.de> <1386572952-1191-7-git-send-email-mgorman@suse.de>
In-Reply-To: <1386572952-1191-7-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Alex Thorlton <athorlton@sgi.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 12/09/2013 02:09 AM, Mel Gorman wrote:
> The anon_vma lock prevents parallel THP splits and any associated complexity
> that arises when handling splits during THP migration. This patch checks
> if the lock was successfully acquired and bails from THP migration if it
> failed for any reason.
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
