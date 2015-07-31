Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 5C1B96B0253
	for <linux-mm@kvack.org>; Fri, 31 Jul 2015 02:09:10 -0400 (EDT)
Received: by pabkd10 with SMTP id kd10so35448848pab.2
        for <linux-mm@kvack.org>; Thu, 30 Jul 2015 23:09:10 -0700 (PDT)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id ba9si7916512pdb.88.2015.07.30.23.09.08
        for <linux-mm@kvack.org>;
        Thu, 30 Jul 2015 23:09:09 -0700 (PDT)
Date: Fri, 31 Jul 2015 15:14:03 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [RFC PATCH 00/10] Remove zonelist cache and high-order watermark
 checking
Message-ID: <20150731061403.GC15912@js1304-P5Q-DELUXE>
References: <1437379219-9160-1-git-send-email-mgorman@suse.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1437379219-9160-1-git-send-email-mgorman@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.com>
Cc: Linux-MM <linux-mm@kvack.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Pintu Kumar <pintu.k@samsung.com>, Xishi Qiu <qiuxishi@huawei.com>, Gioh Kim <gioh.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@techsingularity.net>

On Mon, Jul 20, 2015 at 09:00:09AM +0100, Mel Gorman wrote:
> From: Mel Gorman <mgorman@suse.de>
> 
> This series started with the idea to move LRU lists to pgdat but this
> part was more important to start with. It was written against 4.2-rc1 but
> applies to 4.2-rc3.
> 
> The zonelist cache has been around for a long time but it is of dubious merit
> with a lot of complexity. There are a few reasons why it needs help that
> are explained in the first patch but the most important is that a failed
> THP allocation can cause a zone to be treated as "full". This potentially
> causes unnecessary stalls, reclaim activity or remote fallbacks. Maybe the
> issues could be fixed but it's not worth it.  The series places a small
> number of other micro-optimisations on top before examining watermarks.
> 
> High-order watermarks are something that can cause high-order allocations to
> fail even though pages are free. This was originally to protect high-order
> atomic allocations but there is a much better way that can be handled using
> migrate types. This series uses page grouping by mobility to preserve some
> pageblocks for high-order allocations with the size of the reservation
> depending on demand. kswapd awareness is maintained by examining the free
> lists. By patch 10 in this series, there are no high-order watermark checks
> while preserving the properties that motivated the introduction of the
> watermark checks.

I guess that removal of zonelist cache and high-order watermarks has
different purpose and different set of reader. It is better to
separate this two kinds of patches next time to help reviewer to see
what they want to see.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
