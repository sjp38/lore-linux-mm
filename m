Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f43.google.com (mail-qg0-f43.google.com [209.85.192.43])
	by kanga.kvack.org (Postfix) with ESMTP id 8486A6B0036
	for <linux-mm@kvack.org>; Thu, 22 May 2014 12:00:46 -0400 (EDT)
Received: by mail-qg0-f43.google.com with SMTP id 63so5998929qgz.16
        for <linux-mm@kvack.org>; Thu, 22 May 2014 09:00:46 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id o9si273591qac.99.2014.05.22.09.00.45
        for <linux-mm@kvack.org>;
        Thu, 22 May 2014 09:00:45 -0700 (PDT)
Message-ID: <537E1D4E.4040407@redhat.com>
Date: Thu, 22 May 2014 11:52:46 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/3] fs/superblock: Unregister sb shrinker before ->kill_sb()
References: <1400749779-24879-1-git-send-email-mgorman@suse.de> <1400749779-24879-2-git-send-email-mgorman@suse.de>
In-Reply-To: <1400749779-24879-2-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Tim Chen <tim.c.chen@linux.intel.com>, Dave Chinner <david@fromorbit.com>, Yuanhan Liu <yuanhan.liu@linux.intel.com>, Bob Liu <bob.liu@oracle.com>, Jan Kara <jack@suse.cz>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>

On 05/22/2014 05:09 AM, Mel Gorman wrote:
> From: Dave Chinner <david@fromorbit.com>
> 
> We will like to unregister the sb shrinker before ->kill_sb().
> This will allow cached objects to be counted without call to
> grab_super_passive() to update ref count on sb. We want
> to avoid locking during memory reclamation especially when
> we are skipping the memory reclaim when we are out of
> cached objects.

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
