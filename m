Date: Tue, 13 May 2003 02:04:14 -0700
From: Andrew Morton <akpm@digeo.com>
Subject: Re: 2.5.69-mm4
Message-Id: <20030513020414.5ca41817.akpm@digeo.com>
In-Reply-To: <20030513085525.GA7730@hh.idb.hist.no>
References: <20030512225504.4baca409.akpm@digeo.com>
	<87vfwf8h2n.fsf@lapper.ihatent.com>
	<20030513001135.2395860a.akpm@digeo.com>
	<87n0hr8edh.fsf@lapper.ihatent.com>
	<20030513085525.GA7730@hh.idb.hist.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Helge Hafting <helgehaf@aitel.hist.no>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, alexh@ihatent.com, jsimmons@infradead.org
List-ID: <linux-mm.kvack.org>

Helge Hafting <helgehaf@aitel.hist.no> wrote:
>
> > : undefined reference to `active_load_balance'
> 
>  I got this one too

I don't think so.  Please do a `make clean' and try again.

>, as well as:
>  drivers/built-in.o(.text+0x7d534): In function `fb_prepare_logo':
>  : undefined reference to `find_logo'

Is that thing _still_ there?

Does this fix?

diff -puN drivers/video/fbmem.c~fbmem-linkage-fix drivers/video/fbmem.c
--- 25/drivers/video/fbmem.c~fbmem-linkage-fix	2003-05-13 02:03:38.000000000 -0700
+++ 25-akpm/drivers/video/fbmem.c	2003-05-13 02:03:42.000000000 -0700
@@ -655,7 +655,7 @@ int fb_prepare_logo(struct fb_info *info
 	}
 
 	/* Return if no suitable logo was found */
-	fb_logo.logo = find_logo(info->var.bits_per_pixel);
+	fb_logo.logo = fb_find_logo(info->var.bits_per_pixel);
 	
 	if (!fb_logo.logo || fb_logo.logo->height > info->var.yres) {
 		fb_logo.logo = NULL;

_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
