Date: Thu, 12 Apr 2007 18:58:40 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [SLUB 4/5] Resiliency fixups
In-Reply-To: <20070413013650.17093.62480.sendpatchset@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0704121856510.17201@schroedinger.engr.sgi.com>
References: <20070413013633.17093.93334.sendpatchset@schroedinger.engr.sgi.com>
 <20070413013650.17093.62480.sendpatchset@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 12 Apr 2007, Christoph Lameter wrote:

> @@ -532,7 +566,8 @@ static int check_slab(struct kmem_cache 
>  			page,
>  			page->flags,
>  			page->mapping,
> -			page_count(page));
> +			page_count(page));\
> +		dump_stack();


Eek.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.21-rc6/mm/slub.c
===================================================================
--- linux-2.6.21-rc6.orig/mm/slub.c	2007-04-12 18:29:31.000000000 -0700
+++ linux-2.6.21-rc6/mm/slub.c	2007-04-12 18:57:41.000000000 -0700
@@ -569,7 +569,7 @@ static int check_slab(struct kmem_cache 
 			page,
 			page->flags,
 			page->mapping,
-			page_count(page));\
+			page_count(page));
 		dump_stack();
 		return 0;
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
