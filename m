Message-ID: <38021DE1.816F44A2@pobox.com>
Date: Mon, 11 Oct 1999 13:26:57 -0400
From: Jeff Garzik <jgarzik@pobox.com>
MIME-Version: 1.0
Subject: Re: MMIO regions
References: <14328.64984.364562.947945@dukat.scot.redhat.com>
		<Pine.LNX.4.10.9910061600520.29637-100000@imperial.edgeglobal.com> <14338.6581.988257.647691@dukat.scot.redhat.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: James Simmons <jsimmons@edgeglobal.com>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

"Stephen C. Tweedie" wrote:
> You seem to be looking for a solution which doesn't exist, though. :)

He's working on it though :)  http://imperial.edgeglobal.com/~jsimmons


> It is an unfortunate, but true, fact that the broken video hardware
> doesn't let you provide memory mapped access which is (a) fast, (b)
> totally safe, and (c) functional.  Choose which of a, b and c you are
> willing to sacrifice and then we can look for solutions.  DRI sacrifices
> (b), for example, by making the locking cooperative rather than
> compulsory.  The basic unaccelerated fbcon sacrifices (c).  Using VM
> protection would sacrifice (a).  It's not the ideal choice, sadly.

Seems like it would make sense for an fbcon driver to specify the level
of safety (and thus the level of speed penalty).

For the older cards, "slow and safe" shouldn't be a big problem, because
the typical scenario involves a single fbdev application using the
entire screen.  The fbcon/GGI driver would specify a NEED_SLOW_SYNC flag
when it registers.

For newer cards, they get progressively better at having internal
consistency for reads/writes of various MMIO regions and DMAable
operations.   The fbcon/GGI driver for this could specify the FAST flag
because the card can handle concurrent operations.

Regards,

	Jeff




-- 
Custom driver development	|    Never worry about theory as long
Open source programming		|    as the machinery does what it's
				|    supposed to do.  -- R. A. Heinlein
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
