Date: Mon, 8 Sep 2003 11:21:38 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: Differences between VM structs
Message-ID: <20030908182138.GH29479@holomorphy.com>
References: <3F5CADD3.2070404@movaris.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3F5CADD3.2070404@movaris.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kirk True <ktrue@movaris.com>
Cc: Kernel Newbies <kernelnewbies@nl.linux.org>, Linux Memory Manager List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, Sep 08, 2003 at 09:26:59AM -0700, Kirk True wrote:
>     1. Regarding non-contiguous memory allocation, what is the need to 
>        have *virtually* contiguous but not *physically* contiguous
>        pages?

Fragmentation happens.


On Mon, Sep 08, 2003 at 09:26:59AM -0700, Kirk True wrote:
>     2. UtLVMM says that vmalloc is only used in the kernel for storing
>        swap information - yet it's used by a bunch of drivers which
>        are considered part of the kernel; is it just semantics?

No, its usage has probably expanded. Drivers are generally not supposed
to try to use it directly. It's used for things like vmap() too nowadays.


On Mon, Sep 08, 2003 at 09:26:59AM -0700, Kirk True wrote:
>     3. Is vmalloc called from user-mode ever?

No function in the kernel can be called directly from usermode.


On Mon, Sep 08, 2003 at 09:26:59AM -0700, Kirk True wrote:
>     4. Can you state a succint/brief comparison of the difference
>        between kmalloc, malloc, and vmalloc with usage examples of each?

No.


On Mon, Sep 08, 2003 at 09:26:59AM -0700, Kirk True wrote:
>     5. Anonymous memory is memory that is *not* backed by a file, such
>        as the stack or heap space, right? And mmap is called when
>        mapping files into memory, right? The why does mmap deal with
>        anonymous memory (sorry, I'm totally confused here)?

mmap() needed very few extensions to handle the anonymous case.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
