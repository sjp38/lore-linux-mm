Date: Sat, 18 Aug 2001 21:50:04 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: resend Re: [PATCH] final merging patch -- significant mozilla
 speedup.
In-Reply-To: <20010819023548.P1719@athlon.random>
Message-ID: <Pine.LNX.4.33L.0108182149340.5646-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Ben LaHaise <bcrl@redhat.com>, torvalds@transmeta.com, alan@redhat.com, linux-mm@kvack.org, Chris Blizzard <blizzard@redhat.com>
List-ID: <linux-mm.kvack.org>

On Sun, 19 Aug 2001, Andrea Arcangeli wrote:
> On Sat, Aug 18, 2001 at 08:10:50PM -0400, Ben LaHaise wrote:

> > Your patch performs a few odd things like:
> >
> > +       vma->vm_raend = 0;
...
> > which I would argue are incorrect.  Remember that page faults rely on
>
> vm_raend is obviously correct.

Why ?

Rik
--
IA64: a worthy successor to i860.

http://www.surriel.com/		http://distro.conectiva.com/

Send all your spam to aardvark@nl.linux.org (spam digging piggy)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
