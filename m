Received: from ife.ee.ethz.ch (ife-fast.ee.ethz.ch [129.132.24.193])
	by kvack.org (8.8.7/8.8.7) with ESMTP id GAA10197
	for <linux-mm@kvack.org>; Tue, 26 Jan 1999 06:45:20 -0500
Message-ID: <36ADAAC4.82165F6E@ife.ee.ethz.ch>
Date: Tue, 26 Jan 1999 12:45:08 +0100
From: Thomas Sailer <sailer@ife.ee.ethz.ch>
MIME-Version: 1.0
Subject: Re: MM deadlock [was: Re: arca-vm-8...]
References: <Pine.LNX.3.95.990125222327.726A-100000@localhost>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Gerard Roudier <groudier@club-internet.fr>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Gerard Roudier wrote:

> If you tell me that some system XXX is able to quickly free Mega-Bytes of
> physical contiguous memory at any time when it is asked for such a

Noone said it has to happen quickly, it's entirely useful even if
the calling process (and possibly others) will sleep for 10secs.
These allocations are very uncommon, but nevertheless sometimes
necessary for some device (drivers).

> brain-deaded allocation, then for sure, I will never use system XXX,
> because this magic behaviour seems not to be possible without some
> paranoid VM policy that may affect badly performances for normal stuff.

You may well call the devices that need this broken, the problem
is that they are in rather widespread use.

If we don't find an algorithm that doesn't affect preformance for
the normal stuff, (why would something like selecting
a memory region and forcing everything that's currently in the
way to be swapped out not work?), then we should probably have
a special pool for these "perverse" mappings.

But I think there's a rather generic problem: how are you going
to support 32bit PCI busmasters in machines with more than
4Gig main memory? It's conceptually the same as how are you
going to support ISA DMA with more than 16Meg main memory.

32bit only PCI busmasters are very common these days, I don't
know a single PCI soundcard that can do 64bit master (or even slave)
cycles. Also, all PCI soundcards I know which have a hardware
wavetable synth (without sample ROM) require ridiculously
large contiguous allocations (>= 1M) for the synth to work.

> Anything that requires more that 1 PAGE of physical memory at a time on
> running systems is a very bad thing in my opinion. The PAGE is the only

Ok, then remove any soundcard from your system. That might be acceptable
for you, but probably not for 90% of the Linux users.

Tom
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
