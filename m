Date: Wed, 04 Feb 2004 13:35:54 -0600
From: Dave McCracken <dmccr@us.ibm.com>
Subject: Re: Active Memory Defragmentation: Our implementation & problems
Message-ID: <361730000.1075923354@[10.1.1.5]>
In-Reply-To: <Pine.LNX.4.53.0402041402310.2722@chaos>
References: <20040204185446.91810.qmail@web9705.mail.yahoo.com>
 <Pine.LNX.4.53.0402041402310.2722@chaos>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: root@chaos.analogic.com
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

--On Wednesday, February 04, 2004 14:07:52 -0500 "Richard B. Johnson"
<root@chaos.analogic.com> wrote:

> If this is an Intel x86 machine, it is impossible for pages
> to get fragmented in the first place. The hardware allows any
> page, from anywhere in memory, to be concatenated into linear
> virtual address space. Even the kernel address space is virtual.
> The only time you need physically-adjacent pages is if you
> are doing DMA that is more than a page-length at a time. The
> kernel keeps a bunch of those pages around for just that
> purpose.
> 
> So, if you are making a "memory defragmenter", it is a CPU time-sink.

Um, wrong answer.  When you ask for more than one page from the buddy
allocator  (order greater than 0) it always returns physically contiguous
pages.

Also, one of the near-term goals in VM is to be able to allocate and free
large pages from the main memory pools, which requires that something like
order 9 or 10 allocations (based on the architecture) succeed.

Dave McCracken

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
