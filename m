Date: Sun, 19 Aug 2001 03:17:30 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: resend Re: [PATCH] final merging patch -- significant mozilla speedup.
Message-ID: <20010819031730.V1719@athlon.random>
References: <20010819023548.P1719@athlon.random> <Pine.LNX.4.33L.0108182149340.5646-100000@imladris.rielhome.conectiva> <20010819025532.S1719@athlon.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20010819025532.S1719@athlon.random>; from andrea@suse.de on Sun, Aug 19, 2001 at 02:55:32AM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Ben LaHaise <bcrl@redhat.com>, torvalds@transmeta.com, alan@redhat.com, linux-mm@kvack.org, Chris Blizzard <blizzard@redhat.com>
List-ID: <linux-mm.kvack.org>

On Sun, Aug 19, 2001 at 02:55:32AM +0200, Andrea Arcangeli wrote:
> On Sat, Aug 18, 2001 at 09:50:04PM -0300, Rik van Riel wrote:
> > On Sun, 19 Aug 2001, Andrea Arcangeli wrote:
> > > On Sat, Aug 18, 2001 at 08:10:50PM -0400, Ben LaHaise wrote:
> > 
> > > > Your patch performs a few odd things like:
> > > >
> > > > +       vma->vm_raend = 0;
> > ...
> > > > which I would argue are incorrect.  Remember that page faults rely on
> > >
> > > vm_raend is obviously correct.
> > 
> > Why ?
> 
> Do you know of any piece of code that touches vm_raend without the the
> mmap_sem acquired? If yes you will change my mind about it otherwise you
> will know why.

btw, while my change to madvise is obviously correct (madvise holds the
write sem), I noticed now that the other code changing vm_raend is racy
(but this is totally unrelated to my changes): the nopage callback
during the page fault updates the vm_raend with only the read semaphore
acquired so multiple threads could get confused, however it seems a
controlled race that cannot harm.

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
