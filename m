From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <200003011734.JAA74642@google.engr.sgi.com>
Subject: Re: [RFC] [RFT] Shared /dev/zero mmaping feature
Date: Wed, 1 Mar 2000 09:34:53 -0800 (PST)
In-Reply-To: <qwwputenba1.fsf@sap.com> from "Christoph Rohland" at Mar 01, 2000 01:08:06 PM
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Rohland <hans-christoph.rohland@sap.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

> 
> Hi Kanoj and Linus,
> 
> kanoj@google.engr.sgi.com (Kanoj Sarcar) writes:
> 
> > [snip] 
> >
> > I do not believe there is any good reason to expose the special
> > shared memory segment used as a place holder for all /dev/zero
> > mappings to users via ipc* commands. This special segment exists
> > only because we want to reduce kernel code duplication, and all the
> > zshmid_kernel/ zero_id checks just make sure that regular shared
> > memory works pretty much the way it did before. (One thing I am
> > unhappy about is that this special segment eats up a shm id, but
> > that's probably not too bad).
> 
> The appended proposal reduces code duplication and complexity a
> lot. (The diff47 needs your patches against other files added.)
>

What you have sent is what I used as a first draft for the implementation.
The good part of it is that it reduces code duplication. The _really_ bad
part is that it penalizes users in terms of numbers of shared memory 
segments, max size of /dev/zero mappings, and limitations imposed by
shm_ctlmax/shm_ctlall/shm_ctlmni etc. I do not think taking up a 
shmid for each /dev/zero mapping is a good idea ...

Furthermore, I did not want to change behavior of information returned
by ipc* and various procfs commands, as well as swapout behavior, thus
the creation of the zmap_list. I decided a few lines of special case
checking in a handful of places was a much better option.

If the current /dev/zero stuff hampers any plans you have with shm code 
(eg page cachification), I would be willing to talk about it ...

Kanoj

> I would vote to apply diff48 to the standard kernel. For me the whole
> solution is still a workaround. 
> 
> Greetings
> 		Christoph
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
