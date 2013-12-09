Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f177.google.com (mail-we0-f177.google.com [74.125.82.177])
	by kanga.kvack.org (Postfix) with ESMTP id 26C936B009B
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 09:09:56 -0500 (EST)
Received: by mail-we0-f177.google.com with SMTP id u56so3428816wes.22
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 06:09:55 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id wx3si4616393wjb.102.2013.12.09.06.09.54
        for <linux-mm@kvack.org>;
        Mon, 09 Dec 2013 06:09:55 -0800 (PST)
Message-ID: <52A5CF2F.6090802@redhat.com>
Date: Mon, 09 Dec 2013 09:09:51 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 02/18] mm: numa: Call MMU notifiers on THP migration
References: <1386572952-1191-1-git-send-email-mgorman@suse.de> <1386572952-1191-3-git-send-email-mgorman@suse.de>
In-Reply-To: <1386572952-1191-3-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Alex Thorlton <athorlton@sgi.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 12/09/2013 02:08 AM, Mel Gorman wrote:
> MMU notifiers must be called on THP page migration or secondary MMUs will
> get very confused.
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
