Date: Mon, 11 Oct 1999 19:14:40 -0400 (EDT)
From: James Simmons <jsimmons@edgeglobal.com>
Subject: Re: MMIO regions
In-Reply-To: <38021DE1.816F44A2@pobox.com>
Message-ID: <Pine.LNX.4.10.9910111359230.20596-100000@imperial.edgeglobal.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeff Garzik <jgarzik@pobox.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 11 Oct 1999, Jeff Garzik wrote:

> > It is an unfortunate, but true, fact that the broken video hardware
> > doesn't let you provide memory mapped access which is (a) fast, (b)
> > totally safe, and (c) functional.  Choose which of a, b and c you are
> > willing to sacrifice and then we can look for solutions.  DRI sacrifices
> > (b), for example, by making the locking cooperative rather than
> > compulsory.  The basic unaccelerated fbcon sacrifices (c).  Using VM
> > protection would sacrifice (a).  It's not the ideal choice, sadly.
> 
> Seems like it would make sense for an fbcon driver to specify the level
> of safety (and thus the level of speed penalty).

Well the new system I have implemented has elminated porting MMIO regions
to userspace. This makes way for DRI or any other solutions that might
come down the road. Also I have written fbcon to release the console
system on explict opening of fbdev. This way no accels are running in the
kernel while something like X is running. Especially if something like DRI
is running. This prevents any possible conflicts. Yes I sacrificed some
functionality of the current fbcon for DRI. I hope DRI will in turn help
support fbcon and help us write drivers. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
