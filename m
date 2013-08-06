Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id F31C76B0031
	for <linux-mm@kvack.org>; Tue,  6 Aug 2013 04:48:53 -0400 (EDT)
Date: Tue, 6 Aug 2013 17:48:53 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 4/4] mm, page_alloc: optimize batch count in
 free_pcppages_bulk()
Message-ID: <20130806084852.GA22782@lge.com>
References: <1375778620-31593-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1375778620-31593-4-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1375778620-31593-4-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>

On Tue, Aug 06, 2013 at 05:43:40PM +0900, Joonsoo Kim wrote:
> If we use a division operation, we can compute a batch count more closed
> to ideal value. With this value, we can finish our job within
> MIGRATE_PCPTYPES iteration. In addition, batching to free more pages
> may be helpful to cache usage.
> 
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Oops... Sorry.
Please ignore this one.
This patch is already submitted few seconds ago :)

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
