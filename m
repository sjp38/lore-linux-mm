Date: Mon, 1 Jul 2002 23:06:11 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: Big memory, no struct page allocation
Message-ID: <20020702060611.GT25360@holomorphy.com>
References: <3D1F5034.9060409@shaolinmicro.com> <Pine.LNX.4.44L.0207011447190.25136-100000@imladris.surriel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44L.0207011447190.25136-100000@imladris.surriel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: David Chow <davidchow@shaolinmicro.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 1 Jul 2002, David Chow wrote:
>> In other words, even I have 2G physical memory, I cannot have benefits
>> of using all memory for pagecache, this also means I cannot create any
>> cache beyong a 1G size in kernel. That's a pitty for 32-bit systems,
>> with himem, how does it work?

On Mon, Jul 01, 2002 at 02:48:00PM -0300, Rik van Riel wrote:
> Pagecache can use highmem just fine.
> regards,
> Rik

Yes, pagecache doesn't care where it is, it just works with the
struct pages for the memory. Things that are more internal like
dcache and buffer cache need to be allocated from ZONE_NORMAL,
as the kernel actually touches that memory directly.


Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
