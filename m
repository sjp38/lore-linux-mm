Date: Sat, 18 Aug 2001 21:54:21 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: resend Re: [PATCH] final merging patch -- significant mozilla
 speedup.
In-Reply-To: <20010819023548.P1719@athlon.random>
Message-ID: <Pine.LNX.4.33L.0108182152410.5646-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Ben LaHaise <bcrl@redhat.com>, torvalds@transmeta.com, alan@redhat.com, linux-mm@kvack.org, Chris Blizzard <blizzard@redhat.com>
List-ID: <linux-mm.kvack.org>

On Sun, 19 Aug 2001, Andrea Arcangeli wrote:
> On Sat, Aug 18, 2001 at 08:10:50PM -0400, Ben LaHaise wrote:

> > trees to see what kind of an effect it has on performance compared to the
> > avl tree?
>
> I posted some benchmark result a few minutes ago (the numbers says
> there were no implementation bugs).

Oh, and now that I think about this ... ;)

Your numbers show better insert/removal behaviour, but
isn't LOOKUP the common thing done with the VMAs in the
tree ?

Doesn't an rb tree give longer lookup paths or is this
something which should balance out in the real world?

regards,

Rik
--
IA64: a worthy successor to i860.

http://www.surriel.com/		http://distro.conectiva.com/

Send all your spam to aardvark@nl.linux.org (spam digging piggy)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
