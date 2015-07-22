Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f177.google.com (mail-ie0-f177.google.com [209.85.223.177])
	by kanga.kvack.org (Postfix) with ESMTP id C9FF76B0038
	for <linux-mm@kvack.org>; Tue, 21 Jul 2015 20:11:33 -0400 (EDT)
Received: by iecri3 with SMTP id ri3so60287473iec.2
        for <linux-mm@kvack.org>; Tue, 21 Jul 2015 17:11:33 -0700 (PDT)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com. [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id e3si46865932pdc.50.2015.07.21.17.11.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Jul 2015 17:11:33 -0700 (PDT)
Received: by pachj5 with SMTP id hj5so128336859pac.3
        for <linux-mm@kvack.org>; Tue, 21 Jul 2015 17:11:33 -0700 (PDT)
Date: Tue, 21 Jul 2015 17:11:31 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 04/10] mm, page_alloc: Remove unnecessary taking of a
 seqlock when cpusets are disabled
In-Reply-To: <1437379219-9160-5-git-send-email-mgorman@suse.com>
Message-ID: <alpine.DEB.2.10.1507211710090.12650@chino.kir.corp.google.com>
References: <1437379219-9160-1-git-send-email-mgorman@suse.com> <1437379219-9160-5-git-send-email-mgorman@suse.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.com>
Cc: Linux-MM <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Pintu Kumar <pintu.k@samsung.com>, Xishi Qiu <qiuxishi@huawei.com>, Gioh Kim <gioh.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

On Mon, 20 Jul 2015, Mel Gorman wrote:

> From: Mel Gorman <mgorman@suse.de>
> 
> There is a seqcounter that protects spurious allocation fails when a task
> is changing the allowed nodes in a cpuset. There is no need to check the
> seqcounter until a cpuset exists.
> 
> Signed-off-by: Mel Gorman <mgorman@sujse.de>

Acked-by: David Rientjes <rientjes@google.com>

but there's a typo in your email address in the signed-off-by line.  Nice 
to know you actually type them by hand though :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
