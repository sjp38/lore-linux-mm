Received: from root by main.gmane.org with local (Exim 3.35 #1 (Debian))
	id 18cXsW-0000mO-00
	for <linux-mm@kvack.org>; Sat, 25 Jan 2003 22:30:16 +0100
From: "Andres Salomon" <dilinger@voxel.net>
Subject: Re: 2.5.59-mm5
Date: Sat, 25 Jan 2003 03:33:24 -0500
Message-ID: <pan.2003.01.25.08.33.21.351761@voxel.net>
References: <20030123195044.47c51d39.akpm@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

My atyfb_base.c compile fix (from 2.5.54) still hasn't found its way into
any of the main kernel trees.  The original patch generates a reject
against 2.5.59-mm5, so here's an updated patch.


On Thu, 23 Jan 2003 19:50:44 -0800, Andrew Morton wrote:

> http://www.zip.com.au/~akpm/linux/patches/2.5/2.5.59/2.5.59-mm5/
> 
> .  -mm3 and -mm4 were not announced - they were sync-up patches as we
>   worked on the I/O scheduler.
> 
> .  -mm5 has the first cut of Nick Piggin's anticipatory I/O scheduler.
>   Here's the scoop:
> 
[...]
> 
> anticipatory_io_scheduling-2_5_59-mm3.patch
>   Subject: [PATCH] 2.5.59-mm3 antic io sched
> 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/


--- a/drivers/video/aty/atyfb_base.c    2003-01-25 03:02:35.000000000 -0500
+++ b/drivers/video/aty/atyfb_base.c    2003-01-25 03:21:48.000000000 -0500
@@ -2587,12 +2587,12 @@
	if (info->screen_base)
		iounmap((void *) info->screen_base);
 #ifdef __BIG_ENDIAN
-	if (info->cursor && par->cursor->ram)
+	if (par->cursor && par->cursor->ram)
		iounmap(par->cursor->ram);
 #endif
 #endif
-	if (info->cursor)
-		kfree(info->cursor);
+	if (par->cursor)
+		kfree(par->cursor);
 #ifdef __sparc__
	if (par->mmap_map)
		kfree(par->mmap_map);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
