Subject: Re: [RFC] [RFT] Shared /dev/zero mmaping feature
References: <200003011734.JAA74642@google.engr.sgi.com>
From: Christoph Rohland <hans-christoph.rohland@sap.com>
Date: 01 Mar 2000 18:55:12 +0100
In-Reply-To: kanoj@google.engr.sgi.com's message of "Wed, 1 Mar 2000 09:34:53 -0800 (PST)"
Message-ID: <qww66v6mv7j.fsf@sap.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Cc: Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

kanoj@google.engr.sgi.com (Kanoj Sarcar) writes:

> What you have sent is what I used as a first draft for the implementation.
> The good part of it is that it reduces code duplication. The _really_ bad
> part is that it penalizes users in terms of numbers of shared memory 
> segments, max size of /dev/zero mappings, and limitations imposed by
> shm_ctlmax/shm_ctlall/shm_ctlmni etc. I do not think taking up a 
> shmid for each /dev/zero mapping is a good idea ...

We can tune all these parameters at runtime. This should not be a
reason.

> Furthermore, I did not want to change behavior of information returned
> by ipc* and various procfs commands, as well as swapout behavior, thus
> the creation of the zmap_list. I decided a few lines of special case
> checking in a handful of places was a much better option.

IMHO all this SYSV ipc stuff is a totally broken API and many agree
with me. I do not care to clutter up the output of it a little bit for
this feature.

Nobody can know who is creating private IPC segments. So nobody should
be irritated by some more segments displayed/used.

In the contrary: I like the ability to restrict the usage of these
segments with the ipc parameters. Keep in mind you can stack a lot of
segments for a DOS attack. and all the segments will use the whole
memory.

> If the current /dev/zero stuff hampers any plans you have with shm code 
> (eg page cachification), I would be willing to talk about it ...

It makes shm fs a lot more work. And the special handling slows down
shm handling.

Greetings
		Christoph
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
