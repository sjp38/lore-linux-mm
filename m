Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 2D3506B004D
	for <linux-mm@kvack.org>; Tue,  6 Aug 2013 18:24:00 -0400 (EDT)
Date: Tue, 6 Aug 2013 15:23:57 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm, page_alloc: optimize batch count in
 free_pcppages_bulk()
Message-Id: <20130806152357.40031f6702c92ce9f0d10fca@linux-foundation.org>
In-Reply-To: <1375778440-31503-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1375778440-31503-1-git-send-email-iamjoonsoo.kim@lge.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>

On Tue,  6 Aug 2013 17:40:40 +0900 Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:

> If we use a division operation, we can compute a batch count more closed
> to ideal value. With this value, we can finish our job within
> MIGRATE_PCPTYPES iteration. In addition, batching to free more pages
> may be helpful to cache usage.
> 

hm, maybe.  The .text got 120 bytes larger so the code now will
eject two of someone else's cachelines, which can't be good.  I need
more convincing, please ;)

(bss got larger too - I don't have a clue why this happens).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
