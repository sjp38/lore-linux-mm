Date: Fri, 8 Jun 2001 14:51:32 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: Background scanning change on 2.4.6-pre1
In-Reply-To: <Pine.LNX.4.21.0106081658500.2422-100000@freak.distro.conectiva>
Message-ID: <Pine.LNX.4.31.0106081439540.7448-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: "David S. Miller" <davem@redhat.com>, Mike Galbraith <mikeg@wen-online.de>, Zlatko Calusic <zlatko.calusic@iskon.hr>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Fri, 8 Jun 2001, Marcelo Tosatti wrote:
>
> How do you think the problem should be attacked, if you have any opinion
> at all ?

Let's try the "refill_inactive() also does VM scanning" approach, as that
should make sure that we are never in the situation that we haven't taken
the virtually mapped pages sufficiently into account for aging.

I'm making a 2.4.6-pre2 as I write this, give it a whirl. I've been
working with "mem=64M" for a change to verify that it's not obviously
broken. Compared to my 1GB setup it obviously doesn't cach the kernel
trees quite as well, but it seems to be fairly pleasant to work with
nonetheless.

(It is hard for me to judge - it's been some time since I last used a 64M
machine for any amount of time ;)

Please, try things out. We need to have a better feel for the balancing
heuristics.

		Linus


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
