Date: Mon, 1 Jul 2002 14:48:00 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: Big memory, no struct page allocation
In-Reply-To: <3D1F5034.9060409@shaolinmicro.com>
Message-ID: <Pine.LNX.4.44L.0207011447190.25136-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Chow <davidchow@shaolinmicro.com>
Cc: William Lee Irwin III <wli@holomorphy.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 1 Jul 2002, David Chow wrote:

> In other words, even I have 2G physical memory, I cannot have benefits
> of using all memory for pagecache, this also means I cannot create any
> cache beyong a 1G size in kernel. That's a pitty for 32-bit systems,
> with himem, how does it work?

Pagecache can use highmem just fine.

regards,

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
