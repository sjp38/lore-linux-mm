Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 46AE26B13F0
	for <linux-mm@kvack.org>; Wed,  1 Feb 2012 09:59:39 -0500 (EST)
Message-ID: <4F29533E.2030704@redhat.com>
Date: Wed, 01 Feb 2012 09:59:10 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch] mm: compaction: make compact_control order signed
References: <20120201144101.GA5397@elgon.mountain>
In-Reply-To: <20120201144101.GA5397@elgon.mountain>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, kernel-janitors@vger.kernel.org

On 02/01/2012 09:41 AM, Dan Carpenter wrote:
> "order" is -1 when compacting via /proc/sys/vm/compact_memory.  Making
> it unsigned causes a bug in __compact_pgdat() when we test:
>
> 	if (cc->order<  0 || !compaction_deferred(zone, cc->order))
> 		compact_zone(zone, cc);

Good catch!  I had not even thought to check whether
order was signed in struct compact_control, when I
saw code using -1 as an order in various places :)

> Signed-off-by: Dan Carpenter<dan.carpenter@oracle.com>

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
