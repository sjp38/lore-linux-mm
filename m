Date: Fri, 9 May 2003 08:37:45 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: 2.5.69-mm3
Message-ID: <20030509153745.GW8978@holomorphy.com>
References: <20030508013958.157b27b7.akpm@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030508013958.157b27b7.akpm@digeo.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 08, 2003 at 01:39:58AM -0700, Andrew Morton wrote:
> http://www.zip.com.au/~akpm/linux/patches/2.5/2.5.69-mm3.gz
>   Will appear sometime at
> 
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.5/2.5.69/2.5.69-mm3/

I was just looking over this and noticed 2.4.x makes u64 dma_addr_t
conditional on CONFIG_HIGHMEM64G where 2.5.x uses CONFIG_HIGHMEM. It's
clearly not necessary on CONFIG_HIGHMEM4G, hence this obvious (but
untested) patch:

-- wli


diff -prauN linux-2.5.69-1/include/asm-i386/types.h types-2.5.69-1/include/asm-i386/types.h
--- linux-2.5.69-1/include/asm-i386/types.h	Mon Dec 30 20:14:21 2002
+++ types-2.5.69-1/include/asm-i386/types.h	Fri May  9 08:29:57 2003
@@ -51,7 +51,7 @@
 
 /* DMA addresses come in generic and 64-bit flavours.  */
 
-#ifdef CONFIG_HIGHMEM
+#ifdef CONFIG_HIGHMEM64G
 typedef u64 dma_addr_t;
 #else
 typedef u32 dma_addr_t;
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
