Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id AF7D76B0032
	for <linux-mm@kvack.org>; Tue, 23 Apr 2013 23:28:56 -0400 (EDT)
Date: Tue, 23 Apr 2013 20:28:49 -0700
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 2/2] mm, nobootmem: do memset() after memblock_reserve()
Message-ID: <20130424032849.GO2018@cmpxchg.org>
References: <1366619113-28017-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1366619113-28017-2-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1366619113-28017-2-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Yinghai Lu <yinghai@kernel.org>, Jiang Liu <liuj97@gmail.com>

On Mon, Apr 22, 2013 at 05:25:13PM +0900, Joonsoo Kim wrote:
> Currently, we do memset() before reserving the area.
> This may not cause any problem, but it is somewhat weird.
> So change execution order.
> 
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
