Received: from localhost.localdomain (groudier@ppp-104-246.villette.club-internet.fr [194.158.104.246])
	by kvack.org (8.8.7/8.8.7) with ESMTP id PAA16091
	for <linux-mm@kvack.org>; Tue, 26 Jan 1999 15:44:13 -0500
Date: Tue, 26 Jan 1999 21:48:59 +0100 (MET)
From: Gerard Roudier <groudier@club-internet.fr>
Subject: Re: MM deadlock [was: Re: arca-vm-8...]
In-Reply-To: <36ADAAC4.82165F6E@ife.ee.ethz.ch>
Message-ID: <Pine.LNX.3.95.990126210417.374A-100000@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Thomas Sailer <sailer@ife.ee.ethz.ch>
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Tue, 26 Jan 1999, Thomas Sailer wrote:

> Gerard Roudier wrote:
> 
> > If you tell me that some system XXX is able to quickly free Mega-Bytes of
> > physical contiguous memory at any time when it is asked for such a
> 
> Noone said it has to happen quickly, it's entirely useful even if
> the calling process (and possibly others) will sleep for 10secs.
> These allocations are very uncommon, but nevertheless sometimes
> necessary for some device (drivers).

I suggest to allow some application program to decide what stuff to
victimize and to be able to tell the kernel about, but not to ask the
kernel for doing the bad work for you and then critisize it.

> > brain-deaded allocation, then for sure, I will never use system XXX,
> > because this magic behaviour seems not to be possible without some
> > paranoid VM policy that may affect badly performances for normal stuff.
> 
> You may well call the devices that need this broken, the problem
> is that they are in rather widespread use.

There are bunches of things that are widespread used nowadays and that 
should have disappeard since years if people were a bit more concerned 
by technical and progress considerations.

For example, it seems that 32 bits systems are not enough to provide a
flat virtual addressing space far larger than the physical address space
needed for applications (that was the primary goal of virtual memory
invention). If we were powered a bit more by technical considerations, we
should drop support of 32 bits systems immediately since as you know 64
bits systems are available since years and Linux supports them quite well.

Each time we add support or maintain support of crap, we just encourage
crap and allow the mediocrity to last longer that it really deserves. 

A device that requires more contiguous space than 1 PAGE for its 
support is crap. Because designers spared peanuts by not implementing 
address translation tables, we just have to complete their work by 
complexifying O/Ses. The win is 0.02 euro of silicium for them but 
lots of time wasted by O/Ses guys to support the crap.

> If we don't find an algorithm that doesn't affect preformance for
> the normal stuff, (why would something like selecting
> a memory region and forcing everything that's currently in the
> way to be swapped out not work?), then we should probably have
> a special pool for these "perverse" mappings.
> 
> But I think there's a rather generic problem: how are you going
> to support 32bit PCI busmasters in machines with more than
> 4Gig main memory? It's conceptually the same as how are you
> going to support ISA DMA with more than 16Meg main memory.

What the ratio of machines that need 4 GB of more for doing their 
work?
How much does they cost?
What can we do, if some people that have such machines want to use 
IO controllers that are not able to DMA the whole physical space?
We just may suggest them to learn or to get help from a psychiatric, 
but we should not accept to waste time trying to make the crap work 
less worse.

> 32bit only PCI busmasters are very common these days, I don't
> know a single PCI soundcard that can do 64bit master (or even slave)
> cycles. Also, all PCI soundcards I know which have a hardware
> wavetable synth (without sample ROM) require ridiculously
> large contiguous allocations (>= 1M) for the synth to work.

Are you sure a soundcard is really required for systems that run 
with GBs of memory?

> > Anything that requires more that 1 PAGE of physical memory at a time on
> > running systems is a very bad thing in my opinion. The PAGE is the only
> 
> Ok, then remove any soundcard from your system. That might be acceptable
> for you, but probably not for 90% of the Linux users.

A real Linux user is able to make a custom kernel that incorporates some
driver at boot-up, and can live with that. The ones that are whining about
their PinkSocket O/S having problem to load the sound driver module at 
run-time is another busyness in my opinion.

Regards,
   Gerard.

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
