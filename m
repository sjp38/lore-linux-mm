Date: Wed, 15 Mar 2006 17:59:32 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: page migration reorg patch
In-Reply-To: <Pine.LNX.4.64.0603151747290.30472@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0603151757170.30472@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0603151736380.30472@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0603151747290.30472@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

Gosh. Why am I not perfect. Bonk bonk....

Missing include in swap_state.c

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.16-rc6/mm/swap_state.c
===================================================================
--- linux-2.6.16-rc6.orig/mm/swap_state.c	2006-03-11 14:12:55.000000000 -0800
+++ linux-2.6.16-rc6/mm/swap_state.c	2006-03-15 17:53:19.000000000 -0800
@@ -15,6 +15,7 @@
 #include <linux/buffer_head.h>
 #include <linux/backing-dev.h>
 #include <linux/pagevec.h>
+#include <linux/migrate.h>
 
 #include <asm/pgtable.h>
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
