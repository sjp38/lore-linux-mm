Received: from ns1.rad.net.id (ns1.rad.net.id [202.154.1.2])
	by kvack.org (8.8.7/8.8.7) with ESMTP id CAA31556
	for <linux-mm@kvack.org>; Fri, 15 Jan 1999 02:58:47 -0500
Message-ID: <369EF0E5.84F9CFE7@usa.net>
Date: Fri, 15 Jan 1999 14:40:21 +0700
From: Agus Budy Wuysang <supes-1@usa.net>
MIME-Version: 1.0
Subject: Re: MM deadlock [was: Re: arca-vm-8...]
References: <Pine.LNX.3.96.990113201316.9943B-100000@laser.bogus>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@e-mind.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, "Stephen C. Tweedie" <sct@redhat.com>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrea Arcangeli wrote:
> 
> On Wed, 13 Jan 1999, Alan Cox wrote:
> 
> > > >> Could somebody spare a minute to explain why is that so, and what
> > > >> needs to be done to make SHM swapping asynchronous?
> > >
> > > > Maybe because nobody care about shm? I think shm can wait for 2.3 to be
> > > > improved.
> > >
> > > "Nobody"?  Oracle uses large shared memory regions for starters.
> >
> > All the big databases use large shared memory objects.
> 
> I was't aware of that. I noticed that also postgres (a big database) uses
> shm but it's _only_ something like 1 Mbyte (at least during trivial
> usage). With my current code such 1 Mbyte would not be touched unless

Our current database size 1.6Gb, locks & buffers are
using "large" SHM heavily. Due to Linux SHMMAX = 16M,
allocation is divided into serveral 16M segments.

current database buffers = 130,000 * 1024 bytes
locks = 65536 * 18 bytes

Quick Spec:
Dual PPro 200MHz, 256Mb Ram
Kernel 2.2.0-pre6
Progress 7.3C08 via latest iBCS 2.1.x emulator

-- 
+---| Netscape Communicator 4.x |---| Powered by Linux 2.1.x |---+
|/v\ Agus Budy Wuysang                   MIS Department          |
| |  Phone:  +62-21-344-1316 ext 317     GSM: +62-816-1972-051   |
+--------| http://www.rad.net.id/users/personal/s/supes |--------+
-----BEGIN GEEK CODE BLOCK-----
Version: 3.1
GCS/IT dx s: a- C+++ UL++++$ P- L+++(++++) E--- W++ N+++ o? K? w-- O-
M- V-- PS+ PE Y-- PGP t+@ 5 X+ R- tv- b+ DI? D++(+) G e++ h* r+ y++
------END GEEK CODE BLOCK------
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
