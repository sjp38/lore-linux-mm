Date: Fri, 9 May 2003 07:53:07 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: 2.5.69-mm3
Message-ID: <20030509145307.GA8931@holomorphy.com>
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
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.5/2.5.69/2.5.69-mm3/

This comment looks stale; AIUI the behavior coded is what's desired.
This came up in a discussion with some implementors of a language
runtime about the cause of failures to open large files.

-- wli

diff -prauN linux-2.5.69-1/fs/open.c open-2.5.69-1/fs/open.c
--- linux-2.5.69-1/fs/open.c	Wed Apr  9 06:42:36 2003
+++ open-2.5.69-1/fs/open.c	Fri May  9 07:19:25 2003
@@ -902,7 +902,7 @@
 
 /*
  * Called when an inode is about to be open.
- * We use this to disallow opening RW large files on 32bit systems if
+ * We use this to disallow opening large files on 32bit systems if
  * the caller didn't specify O_LARGEFILE.  On 64bit systems we force
  * on this flag in sys_open.
  */
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
