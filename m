Received: from saruman.cs.brown.edu (saruman.cs.brown.edu [128.148.38.24])
	by cs.brown.edu (8.9.3/8.9.3) with ESMTP id KAA03113
	for <linux-mm@kvack.org>; Mon, 6 Dec 1999 10:56:23 -0500 (EST)
Received: (from kma@localhost)
	by saruman.cs.brown.edu (8.9.0/8.9.0) id KAA11703
	for linux-mm@kvack.org; Mon, 6 Dec 1999 10:56:40 -0500 (EST)
Message-ID: <19991206105640.B11531@cs.brown.edu>
Date: Mon, 6 Dec 1999 10:56:40 -0500
From: Keith Adams <kma@cs.brown.edu>
Subject: Re: Linux Without MMU
References: <199912061545.HAA27422@ns1.filetron.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <199912061545.HAA27422@ns1.filetron.com>; from AndreaE on Mon, Dec 06, 1999 at 07:45:56AM -0800
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Dec 06, 1999 at 07:45:56AM -0800, AndreaE wrote:
> AndreaE <AndreaE@linuxstart.com> wrote:
> Hi , 
> ..i'm working on Linux Kernel porting on HardWare Without MMU. This is not impossible ( uCLinux Es. ), but i'm bored to read thousend &
> thousend of code without a Guide Line. My target is port a full playable linux apps on ARM7TDMI ( very low cost & hi performance CPU but without mmu ). I'm using a uCSimm like example. I've difficulties to understand the new gadget from kernel 2.0.38 (uses by uCSim &  Co. ) and kernel 2.2.12 with ARM support.
> 
> Is There anyone that have some experience with this problem or have some tips to tell me ???

I'm not sure what you mean by "uCSimm-like example," or "new gadget,"
but I did a port to the i960 that was very similar to your port. You
have the added advantage of there already being an ARM port of the
standard kernel, so there will be less architecture manual spelunking
for you to do.

I'm afraid there isn't very much useful documentation about the design
of the (uC)linux kernel; I had to figure it out the hard way. If you'd
like a book to introduce you to the kernel, the most helpful one I
found was the O'Reilly book _Writing Linux Device Drivers_. Steer clear
of the _Linux Kernel Internals_ book; it is, if I recall correctly,
misleading in important respects.

> Is There anyone interesting to help me to do it ??

If you've got hardware to donate, I might be able to help.

Keith

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
