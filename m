Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id 9B9046B00CD
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 11:57:49 -0500 (EST)
Received: by mail-wi0-f174.google.com with SMTP id z2so4098185wiv.13
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 08:57:49 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id be2si7153131wib.79.2013.12.09.08.57.48
        for <linux-mm@kvack.org>;
        Mon, 09 Dec 2013 08:57:48 -0800 (PST)
Message-ID: <52A5F687.9010003@redhat.com>
Date: Mon, 09 Dec 2013 11:57:43 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 16/18] mm: numa: Do not automatically migrate KSM pages
References: <1386572952-1191-1-git-send-email-mgorman@suse.de> <1386572952-1191-17-git-send-email-mgorman@suse.de>
In-Reply-To: <1386572952-1191-17-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Alex Thorlton <athorlton@sgi.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 12/09/2013 02:09 AM, Mel Gorman wrote:
> KSM pages can be shared between tasks that are not necessarily related
> to each other from a NUMA perspective. This patch causes those pages to
> be ignored by automatic NUMA balancing so they do not migrate and do not
> cause unrelated tasks to be grouped together.
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
