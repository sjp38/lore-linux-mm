Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id E8D8E6B0038
	for <linux-mm@kvack.org>; Tue, 21 Jul 2015 19:49:11 -0400 (EDT)
Received: by pdjr16 with SMTP id r16so130595659pdj.3
        for <linux-mm@kvack.org>; Tue, 21 Jul 2015 16:49:11 -0700 (PDT)
Received: from mail-pa0-x22b.google.com (mail-pa0-x22b.google.com. [2607:f8b0:400e:c03::22b])
        by mx.google.com with ESMTPS id t3si46683292pdf.232.2015.07.21.16.49.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Jul 2015 16:49:11 -0700 (PDT)
Received: by pachj5 with SMTP id hj5so128066545pac.3
        for <linux-mm@kvack.org>; Tue, 21 Jul 2015 16:49:10 -0700 (PDT)
Date: Tue, 21 Jul 2015 16:49:09 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 02/10] mm, page_alloc: Remove unnecessary parameter from
 zone_watermark_ok_safe
In-Reply-To: <1437379219-9160-3-git-send-email-mgorman@suse.com>
Message-ID: <alpine.DEB.2.10.1507211649000.12650@chino.kir.corp.google.com>
References: <1437379219-9160-1-git-send-email-mgorman@suse.com> <1437379219-9160-3-git-send-email-mgorman@suse.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.com>
Cc: Linux-MM <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Pintu Kumar <pintu.k@samsung.com>, Xishi Qiu <qiuxishi@huawei.com>, Gioh Kim <gioh.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

On Mon, 20 Jul 2015, Mel Gorman wrote:

> From: Mel Gorman <mgorman@suse.de>
> 
> No user of zone_watermark_ok_safe() specifies alloc_flags. This patch
> removes the unnecessary parameter.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
