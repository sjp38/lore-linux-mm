Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id E59096B0035
	for <linux-mm@kvack.org>; Mon, 20 Jan 2014 01:11:00 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id rd3so6566145pab.19
        for <linux-mm@kvack.org>; Sun, 19 Jan 2014 22:11:00 -0800 (PST)
Received: from LGEAMRELO02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id nu8si970pbb.42.2014.01.19.22.10.57
        for <linux-mm@kvack.org>;
        Sun, 19 Jan 2014 22:10:58 -0800 (PST)
Date: Mon, 20 Jan 2014 15:12:02 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm: Improve documentation of page_order
Message-ID: <20140120061202.GB28712@bbox>
References: <520B0B75.4030708@huawei.com>
 <20130814085711.GK2296@suse.de>
 <20130814155205.GA2706@gmail.com>
 <20130814132602.814a88e991e29c5b93bbe22c@linux-foundation.org>
 <20130814222241.GQ2296@suse.de>
 <20140117143221.GA24851@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140117143221.GA24851@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Xishi Qiu <qiuxishi@huawei.com>, riel@redhat.com, aquini@redhat.com, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Fri, Jan 17, 2014 at 02:32:21PM +0000, Mel Gorman wrote:
> Developers occasionally try and optimise PFN scanners by using page_order
> but miss that in general it requires zone->lock. This has happened twice for
> compaction.c and rejected both times.  This patch clarifies the documentation
> of page_order and adds a note to compaction.c why page_order is not used.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Except Laura pointed out,

Acked-by: Minchan Kim <minchan@kernel.org>

Thanks for following up this issue without forgetting.
-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
