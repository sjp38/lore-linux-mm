Date: Thu, 29 May 2003 01:49:59 -0700
From: Andrew Morton <akpm@digeo.com>
Subject: Re: 2.5.70-mm2
Message-Id: <20030529014959.757871fa.akpm@digeo.com>
In-Reply-To: <20030529012914.2c315dad.akpm@digeo.com>
References: <20030529012914.2c315dad.akpm@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton <akpm@digeo.com> wrote:
>
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.5/2.5.70/2.5.70-mm2/

urgh, sorry.  It has some extra debug which will generate a storm of
warnings with ext2.  Delete the below line.


diff -puN mm/page_alloc.c~x mm/page_alloc.c
--- 25/mm/page_alloc.c~x	2003-05-29 01:48:25.000000000 -0700
+++ 25-akpm/mm/page_alloc.c	2003-05-29 01:48:29.000000000 -0700
@@ -256,7 +256,6 @@ static inline void free_pages_check(cons
 			1 << PG_locked	|
 			1 << PG_active	|
 			1 << PG_reclaim	|
-			1 << PG_checked	|
 			1 << PG_writeback )))
 		bad_page(function, page);
 	if (PageDirty(page))

_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
