Date: Wed, 21 May 2003 16:13:16 +0400
From: Ivan Kokshaysky <ink@jurassic.park.msu.ru>
Subject: Re: 2.5.69-mm7
Message-ID: <20030521161316.A3541@jurassic.park.msu.ru>
References: <20030519012336.44d0083a.akpm@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030519012336.44d0083a.akpm@digeo.com>; from akpm@digeo.com on Mon, May 19, 2003 at 01:23:36AM -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: Jaroslav Kysela <perex@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 19, 2003 at 01:23:36AM -0700, Andrew Morton wrote:
> sound-core-memalloc-build-fix.patch
>   soubd/core/memalloc.c needs mm.h

Ditto sound/core/sgbuf.c, at least on alpha, for
mem_map and other page stuff.

Ivan.

--- 2.5/sound/core/sgbuf.c	Mon Apr  7 21:31:57 2003
+++ linux/sound/core/sgbuf.c	Mon Apr 14 19:15:11 2003
@@ -23,6 +23,7 @@
 #include <linux/version.h>
 #include <linux/pci.h>
 #include <linux/slab.h>
+#include <linux/mm.h>
 #include <linux/vmalloc.h>
 #include <sound/memalloc.h>
 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
