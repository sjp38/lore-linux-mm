Date: Thu, 26 Jun 2003 13:10:05 -0700
From: Andrew Morton <akpm@digeo.com>
Subject: Re: [RFC] My research agenda for 2.7
Message-Id: <20030626131005.4609acb5.akpm@digeo.com>
In-Reply-To: <Pine.LNX.4.53.0306262030500.5910@skynet>
References: <200306250111.01498.phillips@arcor.de>
	<20030625092938.GA13771@skynet.ie>
	<200306262100.40707.phillips@arcor.de>
	<Pine.LNX.4.53.0306262030500.5910@skynet>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: phillips@arcor.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Mel Gorman <mel@csn.ul.ie> wrote:
>
> Buddy allocators, including the
>  one implemented in Linux, do not record what order allocation a struct
>  page belongs to.

We can do that.


--- 25/mm/page_alloc.c~a	2003-06-26 13:09:11.000000000 -0700
+++ 25-akpm/mm/page_alloc.c	2003-06-26 13:09:24.000000000 -0700
@@ -123,6 +123,7 @@ static void prep_compound_page(struct pa
 		SetPageCompound(p);
 		p->lru.next = (void *)page;
 	}
+	page[1].index = order;
 }
 
 static void destroy_compound_page(struct page *page, unsigned long order)

_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
