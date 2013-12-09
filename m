Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id A69F66B00CB
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 11:57:18 -0500 (EST)
Received: by mail-wi0-f176.google.com with SMTP id hq4so4103613wib.15
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 08:57:18 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id ch1si1158808wib.55.2013.12.09.08.57.17
        for <linux-mm@kvack.org>;
        Mon, 09 Dec 2013 08:57:17 -0800 (PST)
Message-ID: <52A5F669.30701@redhat.com>
Date: Mon, 09 Dec 2013 11:57:13 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 15/18] mm: numa: Trace tasks that fail migration due to
 rate limiting
References: <1386572952-1191-1-git-send-email-mgorman@suse.de> <1386572952-1191-16-git-send-email-mgorman@suse.de>
In-Reply-To: <1386572952-1191-16-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Alex Thorlton <athorlton@sgi.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 12/09/2013 02:09 AM, Mel Gorman wrote:
> A low local/remote numa hinting fault ratio is potentially explained by
> failed migrations. This patch adds a tracepoint that fires when migration
> fails due to migration rate limitation.
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
