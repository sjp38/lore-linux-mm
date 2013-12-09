Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 937736B009D
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 09:14:26 -0500 (EST)
Received: by mail-wi0-f178.google.com with SMTP id bz8so3658337wib.11
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 06:14:26 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id k7si6794685wic.54.2013.12.09.06.14.25
        for <linux-mm@kvack.org>;
        Mon, 09 Dec 2013 06:14:25 -0800 (PST)
Message-ID: <52A5D03C.1040100@redhat.com>
Date: Mon, 09 Dec 2013 09:14:20 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 03/18] mm: Clear pmd_numa before invalidating
References: <1386572952-1191-1-git-send-email-mgorman@suse.de> <1386572952-1191-4-git-send-email-mgorman@suse.de>
In-Reply-To: <1386572952-1191-4-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Alex Thorlton <athorlton@sgi.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 12/09/2013 02:08 AM, Mel Gorman wrote:
> pmdp_invalidate clears the present bit without taking into account that it
> might be in the _PAGE_NUMA bit leaving the PMD in an unexpected state. Clear
> pmd_numa before invalidating.
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
