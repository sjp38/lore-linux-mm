Date: Mon, 8 Jan 2001 13:57:00 +0000
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: Subtle MM bug
Message-ID: <20010108135700.O9321@redhat.com>
References: <200101080602.WAA02132@pizda.ninka.net> <Pine.LNX.4.10.10101072223160.29065-100000@penguin.transmeta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.10.10101072223160.29065-100000@penguin.transmeta.com>; from torvalds@transmeta.com on Sun, Jan 07, 2001 at 10:42:11PM -0800
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: "David S. Miller" <davem@redhat.com>, Rik van Riel <riel@conectiva.com.br>, Marcelo Tosatti <marcelo@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Sun, Jan 07, 2001 at 10:42:11PM -0800, Linus Torvalds wrote:
> 
> and just get rid of all the logic to try to "find the best mm". It's bogus
> anyway: we should get perfectly fair access patterns by just doing
> everything in round-robin

Definitely.

> Then, with something like the above, we just try to make sure that we scan
> the whole virtual memory space every once in a while. Make the "every once
> in a while" be some simple heuristic like "try to keep the active list to
> less than 50% of all memory".

... which will produce an enormous storm of soft page faults for
workloads involving mmaping large amounts of data or where we have
a lot of space devoted to anonymous pages, such as static
computational workloads.

The idea of an inactive list target is sound, but it needs to be based
on memory pressure: we don't need anything like 50% if we aren't under
any pressure, so compute-bound workloads with large data sets can
achieve stability.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
