Date: Fri, 19 May 2000 12:24:30 -0700
From: Brian Pomerantz <bapper@piratehaven.org>
Subject: Re: PATCH: Enhance queueing/scsi-midlayer to handle kiobufs. [Re: Request splits]
Message-ID: <20000519122430.A8507@skull.piratehaven.org>
References: <20000519091718.A4083@skull.piratehaven.org> <Pine.LNX.4.10.10005191936160.631-100000@linux.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
In-Reply-To: <Pine.LNX.4.10.10005191936160.631-100000@linux.local>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: =?iso-8859-1?Q?G=E9rard_Roudier?= <groudier@club-internet.fr>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Chaitanya Tumuluri <chait@getafix.engr.sgi.com>, Eric Youngdale <eric@andante.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Douglas Gilbert <dgilbert@interlog.com>, linux-scsi@vger.rutgers.edu, chait@sgi.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 19, 2000 at 08:11:10PM +0200, Gerard Roudier wrote:
> 
> Low-level drivers have limits on number of scatter entries. They can do
> large transfers if scatter entries point to large data area. Rather than
> hacking low-level drivers that are very critical piece of code that
> require specific knowledge and documentation about the hardware, I
> recommend you to hack the peripheral driver used for the Ciprico and let
> it use large contiguous buffers (If obviously you want to spend your time
> for this device that should go to compost, IMO).
> 
> Wanting to provide best support for shitty designed hardware does not
> encourage hardware vendors to provide us with well designed hardware. In
> others words, the more we want to support crap, the more we will have to
> support crap.
> 

I really don't want to get into a pissing match but it is obvious to
me that you haven't had any experience with high performance external
RAID solutions.  You will see this sort of performance characteristic
with a lot of these devices.  They are used to put together very large
storage systems (we are looking at building petabtye systems within
two years).

There is no way I'm going to hack on the proprietary RAID controller
in this system and even if I wanted to or could, I'm quite certain
there is a reason for needing the large transaction size.  When you
take into account the maximum transaction unit on each drive (usually
64KB), the fact that there are 8 data drives, then you have parity
calculation, latency of the transfer, and various points at which data
is cached and queued up before there is a complete transaction, then
you come up with the magic number.  These things were designed for
large streaming data and they do it VERY well.

If you have a hardware RAID 3 or RAID 5 solution that will give me
this kind of performance for the price point and size that these
Ciprico units have, then I would LOVE to hear it because I'm in the
market for buying several of them.  If you can find me a way of
getting >= 150MB/s streaming I/O on a single I/O server for my cluster
and fill an order for 2 I/O servers for under $100K, then I may
consider something other than the Ciprico 7000.  They deliver this
performance for a very attractive price.  And in a year, I'll come
back and buy a fifty more.


BAPper
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
