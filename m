Date: Wed, 16 Jan 2002 01:15:00 -0800
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: question in vmalloc
Message-ID: <20020116011500.A739@holomorphy.com>
References: <1011163587.1038.2.camel@star4.planet.rcn.com.hk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <1011163587.1038.2.camel@star4.planet.rcn.com.hk>; from joewong@shaolinmicro.com on Wed, Jan 16, 2002 at 02:46:27PM +0800
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Joe Wong <joewong@shaolinmicro.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jan 16, 2002 at 02:46:27PM +0800, Joe Wong wrote:
>   I am new to the kernel area. I would like to know if there is any
> potentail problem on using vmalloc? If the memory returned by vmalloc
> swappable? If so, how I can turn it to unswappable? I have a kernel
> module to will preallocate some huge data strucutres using vmalloc when
> loaded.

Memory allocated by vmalloc() is not swappable. It is virtually
contiguous because the kernel edits its page tables to make it so.
It is not necessarily physically contiguous, though. The amount of
kernel virtual address space available for vmalloc() allocations is
limited, though, as the address space is laid out statically.

This is how it is done in Linux; other kernels may behave differently
(e.g. AIX).


Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
