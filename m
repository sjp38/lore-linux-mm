Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f172.google.com (mail-qc0-f172.google.com [209.85.216.172])
	by kanga.kvack.org (Postfix) with ESMTP id 785796B0036
	for <linux-mm@kvack.org>; Thu, 22 May 2014 12:45:57 -0400 (EDT)
Received: by mail-qc0-f172.google.com with SMTP id l6so6244395qcy.31
        for <linux-mm@kvack.org>; Thu, 22 May 2014 09:45:57 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id j7si490199qai.23.2014.05.22.09.45.56
        for <linux-mm@kvack.org>;
        Thu, 22 May 2014 09:45:56 -0700 (PDT)
Message-ID: <537E1EE6.8080102@redhat.com>
Date: Thu, 22 May 2014 11:59:34 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/3] fs/superblock: Avoid locking counting inodes and
 dentries before reclaiming them
References: <1400749779-24879-1-git-send-email-mgorman@suse.de> <1400749779-24879-3-git-send-email-mgorman@suse.de>
In-Reply-To: <1400749779-24879-3-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Tim Chen <tim.c.chen@linux.intel.com>, Dave Chinner <david@fromorbit.com>, Yuanhan Liu <yuanhan.liu@linux.intel.com>, Bob Liu <bob.liu@oracle.com>, Jan Kara <jack@suse.cz>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>

On 05/22/2014 05:09 AM, Mel Gorman wrote:
> From: Tim Chen <tim.c.chen@linux.intel.com>
> 
> We remove the call to grab_super_passive in call to super_cache_count.
> This becomes a scalability bottleneck as multiple threads are trying to do
> memory reclamation, e.g. when we are doing large amount of file read and
> page cache is under pressure.  The cached objects quickly got reclaimed
> down to 0 and we are aborting the cache_scan() reclaim.  But counting
> creates a log jam acquiring the sb_lock.

> Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Acked-by: Rik van Riel <riel@redhat.com>


-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
