Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id BC4046B0038
	for <linux-mm@kvack.org>; Tue, 21 Jul 2015 20:08:44 -0400 (EDT)
Received: by pabkd10 with SMTP id kd10so56185403pab.2
        for <linux-mm@kvack.org>; Tue, 21 Jul 2015 17:08:44 -0700 (PDT)
Received: from mail-pd0-x22e.google.com (mail-pd0-x22e.google.com. [2607:f8b0:400e:c02::22e])
        by mx.google.com with ESMTPS id el7si46775473pdb.190.2015.07.21.17.08.43
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Jul 2015 17:08:44 -0700 (PDT)
Received: by pdrg1 with SMTP id g1so128435578pdr.2
        for <linux-mm@kvack.org>; Tue, 21 Jul 2015 17:08:43 -0700 (PDT)
Date: Tue, 21 Jul 2015 17:08:42 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 03/10] mm, page_alloc: Remove unnecessary recalculations
 for dirty zone balancing
In-Reply-To: <1437379219-9160-4-git-send-email-mgorman@suse.com>
Message-ID: <alpine.DEB.2.10.1507211703410.12650@chino.kir.corp.google.com>
References: <1437379219-9160-1-git-send-email-mgorman@suse.com> <1437379219-9160-4-git-send-email-mgorman@suse.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.com>
Cc: Linux-MM <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Pintu Kumar <pintu.k@samsung.com>, Xishi Qiu <qiuxishi@huawei.com>, Gioh Kim <gioh.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

On Mon, 20 Jul 2015, Mel Gorman wrote:

> From: Mel Gorman <mgorman@suse.de>
> 
> File-backed pages that will be immediately dirtied are balanced between
> zones but it's unnecessarily expensive. Move consider_zone_balanced into
> the alloc_context instead of checking bitmaps multiple times.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Acked-by: David Rientjes <rientjes@google.com>

consider_zone_dirty eliminates zones over their dirty limits and 
zone_dirty_ok() returns true if zones are under their dirty limits, so the 
naming of both are a little strange.  You might consider changing them 
while you're here.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
