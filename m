Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f41.google.com (mail-ee0-f41.google.com [74.125.83.41])
	by kanga.kvack.org (Postfix) with ESMTP id 059B56B00A6
	for <linux-mm@kvack.org>; Mon,  9 Dec 2013 09:42:24 -0500 (EST)
Received: by mail-ee0-f41.google.com with SMTP id t10so1618462eei.14
        for <linux-mm@kvack.org>; Mon, 09 Dec 2013 06:42:24 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id s8si9748568eeh.248.2013.12.09.06.42.23
        for <linux-mm@kvack.org>;
        Mon, 09 Dec 2013 06:42:24 -0800 (PST)
Message-ID: <52A5D6C9.1080307@redhat.com>
Date: Mon, 09 Dec 2013 09:42:17 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 07/18] mm: numa: Avoid unnecessary work on the failure
 path
References: <1386572952-1191-1-git-send-email-mgorman@suse.de> <1386572952-1191-8-git-send-email-mgorman@suse.de>
In-Reply-To: <1386572952-1191-8-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Alex Thorlton <athorlton@sgi.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 12/09/2013 02:09 AM, Mel Gorman wrote:
> If a PMD changes during a THP migration then migration aborts but the
> failure path is doing more work than is necessary.
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
