Date: Sun, 23 Jun 2002 01:59:14 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: Big memory, no struct page allocation
Message-ID: <20020623085914.GN25360@holomorphy.com>
References: <3D158D1E.1090802@shaolinmicro.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3D158D1E.1090802@shaolinmicro.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Chow <davidchow@shaolinmicro.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Jun 23, 2002 at 04:55:58PM +0800, David Chow wrote:
> Hi, I've got a silly but serious question. I want to allocate a large 
> buffer (>512MB) in kernel. Normally you use __get_free_page and handle 
> it with page pointers. But when get to very large (say 1024MB), I will 
> need to use 2 level of page pointer indirection to carry the page 
> pointer array. I also find the total size of page struct is quite large 
> when using lots of pages, what I want is to use memory pages without 
> struct page, is this possible? By the way, can I use lots of memory in 
> the kernel, something like 1GB of memory allocation when physically RAM 
> available? Please give advise. Thanks.

Try allocating it at boot-time with the bootmem allocator.


Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
