Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 872B46B0087
	for <linux-mm@kvack.org>; Wed, 14 Aug 2013 04:57:17 -0400 (EDT)
Date: Wed, 14 Aug 2013 09:57:11 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: skip the page buddy block instead of one page
Message-ID: <20130814085711.GK2296@suse.de>
References: <520B0B75.4030708@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <520B0B75.4030708@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, riel@redhat.com, Minchan Kim <minchan@kernel.org>, aquini@redhat.com, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed, Aug 14, 2013 at 12:45:41PM +0800, Xishi Qiu wrote:
> A large free page buddy block will continue many times, so if the page 
> is free, skip the whole page buddy block instead of one page.
> 
> Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>

page_order cannot be used unless zone->lock is held which is not held in
this path. Acquiring the lock would prevent parallel allocations from the
buddy allocator (per-cpu allocator would be ok except for refills).  I expect
it would not be a good tradeoff to acquire the lock just to use page_order.

Nak.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
