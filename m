Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id B42436B0031
	for <linux-mm@kvack.org>; Thu, 13 Feb 2014 11:11:21 -0500 (EST)
Received: by mail-wi0-f174.google.com with SMTP id f8so8858376wiw.7
        for <linux-mm@kvack.org>; Thu, 13 Feb 2014 08:11:21 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id jy10si1551222wjc.173.2014.02.13.08.11.19
        for <linux-mm@kvack.org>;
        Thu, 13 Feb 2014 08:11:20 -0800 (PST)
Message-ID: <52FCEE9C.2040001@redhat.com>
Date: Thu, 13 Feb 2014 11:11:08 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] mm/vmscan: not check compaction_ready on promoted
 zones
References: <000101cf2865$2a8411a0$7f8c34e0$%yang@samsung.com>
In-Reply-To: <000101cf2865$2a8411a0$7f8c34e0$%yang@samsung.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Weijie Yang <weijie.yang@samsung.com>, 'Mel Gorman' <mgorman@suse.de>
Cc: 'Andrew Morton' <akpm@linux-foundation.org>, 'Minchan Kim' <minchan@kernel.org>, weijie.yang.kh@gmail.com, 'Linux-MM' <linux-mm@kvack.org>, 'linux-kernel' <linux-kernel@vger.kernel.org>

On 02/12/2014 09:41 PM, Weijie Yang wrote:
> We abort direct reclaim if find the zone is ready for compaction.
> 
> Sometimes the zone is just a promoted highmem zone to force scan
> pinning highmem, which is not the intended zone the caller want to
> alloc page from. In this situation, setting aborted_reclaim to
> indicate the caller turn back to retry allocation is waste of time
> and could cause a loop in __alloc_pages_slowpath().
> 
> This patch do not check compaction_ready() on promoted zones to avoid
> the above situation, only set aborted_reclaim if the caller intended
> zone is ready to compaction.
> 
> Signed-off-by: Weijie Yang <weijie.yang@samsung.com>

Acked-by: Rik van Riel <riel@redhat.com>


-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
