Date: Thu, 15 May 2003 12:51:57 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: 2.5.69-mm5
Message-ID: <20030515195157.GS8978@holomorphy.com>
References: <20030514012947.46b011ff.akpm@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20030514012947.46b011ff.akpm@digeo.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 14, 2003 at 01:29:47AM -0700, Andrew Morton wrote:
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.5/2.5.69/2.5.69-mm5/
> 
> Various fixes.  It should even compile on uniprocessor.
> I dropped all the NFS client changes, which have been in -mm for ages.  A
> number of fixes have been merged into Linus's tree and they need testing on
> their own.


put_page_testzero() does BUG_ON(page_count(page)) when its argument
is p.

-- wli


diff -prauN linux-2.5.69-bk9/include/linux/mm.h numaq-2.5.69-bk9-1/include/linux/mm.h
--- linux-2.5.69-bk9/include/linux/mm.h	2003-05-15 12:01:44.000000000 -0700
+++ numaq-2.5.69-bk9-1/include/linux/mm.h	2003-05-15 12:26:34.000000000 -0700
@@ -214,7 +214,7 @@ struct page {
  */
 #define put_page_testzero(p)				\
 	({						\
-		BUG_ON(page_count(page) == 0);		\
+		BUG_ON(page_count(p) == 0);		\
 		atomic_dec_and_test(&(p)->count);	\
 	})
 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
