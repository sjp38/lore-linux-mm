Date: Fri, 2 Aug 2002 16:40:49 -0700
From: Chris Wedgwood <cw@f00f.org>
Subject: Re: large page patch
Message-ID: <20020802234049.GA28755@tapu.f00f.org>
References: <3D49D45A.D68CCFB4@zip.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3D49D45A.D68CCFB4@zip.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@zip.com.au>
Cc: lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Seth, Rohit" <rohit.seth@intel.com>, "Saxena, Sunil" <sunil.saxena@intel.com>, "Mallick, Asit K" <asit.k.mallick@intel.com>
List-ID: <linux-mm.kvack.org>

On Thu, Aug 01, 2002 at 05:37:46PM -0700, Andrew Morton wrote:

    diff -Naru linux.org/arch/i386/kernel/entry.S linux.lp/arch/i386/kernel/entry.S
    --- linux.org/arch/i386/kernel/entry.S	Mon Feb 25 11:37:53 2002
    +++ linux.lp/arch/i386/kernel/entry.S	Tue Jul  2 15:12:23 2002
    @@ -634,6 +634,10 @@
     	.long SYMBOL_NAME(sys_ni_syscall)	/* 235 reserved for removexattr */
     	.long SYMBOL_NAME(sys_ni_syscall)	/* reserved for lremovexattr */
     	.long SYMBOL_NAME(sys_ni_syscall)	/* reserved for fremovexattr */
    +	.long SYMBOL_NAME(sys_get_large_pages)	/* Get large_page pages */
    +	.long SYMBOL_NAME(sys_free_large_pages)	/* Free large_page pages */
    +	.long SYMBOL_NAME(sys_share_large_pages)/* Share large_page pages */
    +	.long SYMBOL_NAME(sys_unshare_large_pages)/* UnShare large_page pages */


Must large pages be allocated this way?

At some point I would like to see code that mmap's large amounts of
data (over 1GB) and have it take advantage of this once the kernel is
potentially extended to deal with mapping of large and/or variable
sized pages backed to disk.

Also, some scientific applications will malloc(3) gobs of ram, again
in excess of 1GB, is it unreasonable to expect that the kernel will
notice large allocations and try to provide large pages sbrk in
invoked with suitable high values?



  --cw
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
