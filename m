Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f45.google.com (mail-ee0-f45.google.com [74.125.83.45])
	by kanga.kvack.org (Postfix) with ESMTP id 4D6426B0036
	for <linux-mm@kvack.org>; Mon, 19 May 2014 14:12:36 -0400 (EDT)
Received: by mail-ee0-f45.google.com with SMTP id d49so3810589eek.18
        for <linux-mm@kvack.org>; Mon, 19 May 2014 11:12:35 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id d1si15851443eem.85.2014.05.19.11.12.33
        for <linux-mm@kvack.org>;
        Mon, 19 May 2014 11:12:34 -0700 (PDT)
Message-ID: <537A4987.7040007@redhat.com>
Date: Mon, 19 May 2014 14:12:23 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/vmscan.c: use DIV_ROUND_UP for calculation of zone's
 balance_gap and correct comments.
References: <1400472510-24375-1-git-send-email-nasa4836@gmail.com>
In-Reply-To: <1400472510-24375-1-git-send-email-nasa4836@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jianyu Zhan <nasa4836@gmail.com>, akpm@linux-foundation.org, hannes@cmpxchg.org, shli@kernel.org, minchan@kernel.org, mgorman@suse.de, cmetcalf@tilera.com, aquini@redhat.com, mhocko@suse.cz, vdavydov@parallels.com, glommer@openvz.org, dchinner@redhat.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 05/19/2014 12:08 AM, Jianyu Zhan wrote:
> Currently, we use (zone->managed_pages + KSWAPD_ZONE_BALANCE_GAP_RATIO-1) /
> KSWAPD_ZONE_BALANCE_GAP_RATIO to avoid a zero gap value. It's better to
> use DIV_ROUND_UP macro for neater code and clear meaning.
> 
> Besides, the gap value is calculated against the per-zone "managed pages",
> not "present pages". This patch also corrects the comment and do some
> rephrasing.
> 
> Signed-off-by: Jianyu Zhan <nasa4836@gmail.com>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
