Date: Mon, 11 Oct 1999 13:57:50 -0400 (EDT)
From: James Simmons <jsimmons@edgeglobal.com>
Subject: Re: MMIO regions
In-Reply-To: <14338.6581.988257.647691@dukat.scot.redhat.com>
Message-ID: <Pine.LNX.4.10.9910111354090.20596-100000@imperial.edgeglobal.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> You seem to be looking for a solution which doesn't exist, though. :)

Well my next experiment is RTLinux with acceleration. From what I have
been learning SGI kernel has a special schedular for its graphics to
ensure hard real time performace. I want to see how much of a impact
RTLinux wil have with acceleration.    

> It is an unfortunate, but true, fact that the broken video hardware
> doesn't let you provide memory mapped access which is (a) fast, (b)
> totally safe, and (c) functional.  Choose which of a, b and c you are
> willing to sacrifice and then we can look for solutions.  DRI sacrifices
> (b), for example, by making the locking cooperative rather than
> compulsory.  The basic unaccelerated fbcon sacrifices (c).  Using VM
> protection would sacrifice (a).  It's not the ideal choice, sadly.

Well I see SGI uses usemsa which is its version of flocking. If SGI does
it then its the right way :) Yes I think SGI hardware is teh greatest in
the world.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
