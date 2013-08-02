Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 754F56B0032
	for <linux-mm@kvack.org>; Fri,  2 Aug 2013 15:43:38 -0400 (EDT)
Date: Fri, 2 Aug 2013 15:43:33 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 4/4] swap: clean-up #ifdef in page_mapping()
Message-ID: <20130802194333.GW715@cmpxchg.org>
References: <1375409279-16919-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1375409279-16919-4-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1375409279-16919-4-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>

On Fri, Aug 02, 2013 at 11:07:59AM +0900, Joonsoo Kim wrote:
> PageSwapCache() is always false when !CONFIG_SWAP, so compiler
> properly discard related code. Therefore, we don't need #ifdef explicitly.
> 
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
