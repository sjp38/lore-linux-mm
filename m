Date: Fri, 06 Apr 2007 21:21:47 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: Re: [PATCH] Do not cross section boundary when moving pages between mobility lists
In-Reply-To: <20070406114426.GA21653@skynet.ie>
References: <20070406114426.GA21653@skynet.ie>
Message-Id: <20070406211457.C2D0.Y-GOTO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> move-free-pages-between-lists-on-steal-fix-2.patch fixed an issue with a
> BUG_ON() that checked for a page just outside a MAX_ORDER_NR_PAGES boundary. In
> fact, the proper place to check it was earlier. A situation can occur on
> SPARSEMEM where a section boundary is crossed which will cause problems on some
> machines. This patch addresses the problem.
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>

I reviewed it, looks ok. :-)

Acked-by: Yasunori Goto <y-goto@jp.fujitsu.com>

Thanks.

-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
