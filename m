Date: Sat, 9 Jun 2001 00:26:13 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: Background scanning change on 2.4.6-pre1
In-Reply-To: <Pine.LNX.4.21.0106071330060.6510-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.21.0106090024430.10415-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Marcelo Tosatti <marcelo@conectiva.com.br>, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 7 Jun 2001, Linus Torvalds wrote:
> On Thu, 7 Jun 2001, Marcelo Tosatti wrote:

> > time (the old code from Rik which has been replaced by this code tried to 
> > avoid that)
> 
> Now, I think the problem with the old code was that it didn't do _any_
> background page aging if "inactive" was large enough. And that really
> doesn't make all that much sense. Background page aging is needed to
> "sort" the active list, regardless of how many inactive pages there are.

I'll be posting a patch in a few minutes (against 2.4.5-acX, which
was the latest kernel available to me while on holidays with no
net access) which doesn't "roll over" the inactive dirty pages when
we scan the list.

This should make us reclaim the inactive_dirty pages in a much better
LRU order, so this whole background aging limiting stuff becomes close
to moot.

regards,

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
