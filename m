Date: Fri, 8 Jun 2001 21:05:11 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: Background scanning change on 2.4.6-pre1
In-Reply-To: <Pine.LNX.4.21.0106090047320.10415-100000@imladris.rielhome.conectiva>
Message-ID: <Pine.LNX.4.21.0106082102330.24643-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Marcelo Tosatti <marcelo@conectiva.com.br>, "David S. Miller" <davem@redhat.com>, Mike Galbraith <mikeg@wen-online.de>, Zlatko Calusic <zlatko.calusic@iskon.hr>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 9 Jun 2001, Rik van Riel wrote:
> 
> This would work if we had all the anonymous pages on the
> active list, so we have an idea when we have had to "skip"
> too many pages due to being mapped.

Well, we already have an idea of that. Or rather - by making th ecall to
swap_out() unconditional, we never end up skipping anything at all: we
always balance all pools of memory, whether they are active, inactive, or
mapped.

Let's see how people react to -pre2 (and yes, I forgot to bump the version
number, so it claims to be -pre1 still. Don't send me any more bugreports
on that ;)

The way it is in -pre2 will at least not confuse people overmuch wrt the
"why is my machine claiming to be swapping even though it's not doing
anything and the disk light isn't on?" issue..

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
