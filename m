Date: Thu, 20 Apr 2006 20:09:04 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 1/5] mm: remap_vmalloc_range
Message-ID: <20060420180903.GF21660@wotan.suse.de>
References: <20060228202202.14172.60409.sendpatchset@linux.site> <20060228202212.14172.59536.sendpatchset@linux.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20060228202212.14172.59536.sendpatchset@linux.site>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

Hotfix #1


Index: linux-2.6/drivers/media/video/usbvideo/vicam.c
===================================================================
--- linux-2.6.orig/drivers/media/video/usbvideo/vicam.c
+++ linux-2.6/drivers/media/video/usbvideo/vicam.c
@@ -1000,6 +1000,7 @@ vicam_mmap(struct file *file, struct vm_
 	 * It shouldn't have been, so let's try this check again -np
 	 */
 	 if (size > VICAM_FRAMES*VICAM_MAX_FRAME_SIZE)
+		return -EINVAL;
 
 	if (remap_vmalloc_range(vma, cam->framebuf, 0))
 		return -EAGAIN;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
