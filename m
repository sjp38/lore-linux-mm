Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0F11E6B0005
	for <linux-mm@kvack.org>; Thu, 14 Jul 2016 10:45:18 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id 33so53991198lfw.1
        for <linux-mm@kvack.org>; Thu, 14 Jul 2016 07:45:17 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l193si34179273wma.4.2016.07.14.07.45.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 14 Jul 2016 07:45:16 -0700 (PDT)
Subject: Re: [PATCH 2/4] mm: vmstat: account per-zone stalls and pages skipped
 during reclaim -fix
References: <1468404004-5085-1-git-send-email-mgorman@techsingularity.net>
 <1468404004-5085-3-git-send-email-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <4d0fda00-5c08-143d-7b43-845f8337e843@suse.cz>
Date: Thu, 14 Jul 2016 16:45:15 +0200
MIME-Version: 1.0
In-Reply-To: <1468404004-5085-3-git-send-email-mgorman@techsingularity.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, LKML <linux-kernel@vger.kernel.org>

On 07/13/2016 12:00 PM, Mel Gorman wrote:
> As pointed out by Johannes -- the PG prefix seems to stand for page, and
> all stat names that contain it represent some per-page event. PGSTALL is
> not a page event. This patch renames it.
>
> This is a fix for the mmotm patch
> mm-vmstat-account-per-zone-stalls-and-pages-skipped-during-reclaim.patch
>
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
