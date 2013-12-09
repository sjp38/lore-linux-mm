Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f42.google.com (mail-ee0-f42.google.com [74.125.83.42])
	by kanga.kvack.org (Postfix) with ESMTP id D43596B00B9
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 11:14:19 -0500 (EST)
Received: by mail-ee0-f42.google.com with SMTP id e53so1650987eek.15
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 08:14:19 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id w6si10169608eeg.111.2013.12.09.08.14.17
        for <linux-mm@kvack.org>;
        Mon, 09 Dec 2013 08:14:19 -0800 (PST)
Message-ID: <52A5EC56.7080400@redhat.com>
Date: Mon, 09 Dec 2013 11:14:14 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 13/18] mm: numa: Make NUMA-migrate related functions static
References: <1386572952-1191-1-git-send-email-mgorman@suse.de> <1386572952-1191-14-git-send-email-mgorman@suse.de>
In-Reply-To: <1386572952-1191-14-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Alex Thorlton <athorlton@sgi.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 12/09/2013 02:09 AM, Mel Gorman wrote:
> numamigrate_update_ratelimit and numamigrate_isolate_page only have callers
> in mm/migrate.c. This patch makes them static.
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
