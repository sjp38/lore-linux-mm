Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 77E9D6B0253
	for <linux-mm@kvack.org>; Tue, 28 Jul 2015 08:20:25 -0400 (EDT)
Received: by wibxm9 with SMTP id xm9so154553431wib.0
        for <linux-mm@kvack.org>; Tue, 28 Jul 2015 05:20:25 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q9si20044711wiy.83.2015.07.28.05.20.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 28 Jul 2015 05:20:24 -0700 (PDT)
Subject: Re: [PATCH 02/10] mm, page_alloc: Remove unnecessary parameter from
 zone_watermark_ok_safe
References: <1437379219-9160-1-git-send-email-mgorman@suse.com>
 <1437379219-9160-3-git-send-email-mgorman@suse.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <55B77380.8070104@suse.cz>
Date: Tue, 28 Jul 2015 14:20:16 +0200
MIME-Version: 1.0
In-Reply-To: <1437379219-9160-3-git-send-email-mgorman@suse.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.com>, Linux-MM <linux-mm@kvack.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Pintu Kumar <pintu.k@samsung.com>, Xishi Qiu <qiuxishi@huawei.com>, Gioh Kim <gioh.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

On 07/20/2015 10:00 AM, Mel Gorman wrote:
> From: Mel Gorman <mgorman@suse.de>
>
> No user of zone_watermark_ok_safe() specifies alloc_flags. This patch
> removes the unnecessary parameter.
>
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
