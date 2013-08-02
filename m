Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 17F1A6B0032
	for <linux-mm@kvack.org>; Fri,  2 Aug 2013 15:23:00 -0400 (EDT)
Date: Fri, 2 Aug 2013 15:22:54 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 2/2] mm, vmalloc: use well-defined find_last_bit() func
Message-ID: <20130802192254.GT715@cmpxchg.org>
References: <1375408621-16563-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1375408621-16563-2-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1375408621-16563-2-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Joonsoo Kim <js1304@gmail.com>

On Fri, Aug 02, 2013 at 10:57:01AM +0900, Joonsoo Kim wrote:
> Our intention in here is to find last_bit within the region to flush.
> There is well-defined function, find_last_bit() for this purpose and
> it's performance may be slightly better than current implementation.
> So change it.
> 
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
