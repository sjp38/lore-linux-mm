Date: Sat, 9 Jun 2001 00:17:54 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: VM tuning patch, take 2
In-Reply-To: <l0313031bb7457c3ad660@[192.168.239.105]>
Message-ID: <Pine.LNX.4.21.0106090017170.10415-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jonathan Morton <chromi@cyberspace.org>
Cc: Marcelo Tosatti <marcelo@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 7 Jun 2001, Jonathan Morton wrote:

> I forgot to mention, I also have applied the patch which causes
> allocations to wait on kswapd.  As far as I can tell, the actual
> numbers attached to the ageing matter far less than how they are
> applied.

Ahhh cool, this should indeed cause lots of CPU eating problems.

I have a similar patch which makes processes wait on IO completion
when they find too many dirty pages on the inactive_dirty list ;)

Rik
--
Virtual memory is like a game you can't win;
However, without VM there's truly nothing to lose...

http://www.surriel.com/		http://distro.conectiva.com/

Send all your spam to aardvark@nl.linux.org (spam digging piggy)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
