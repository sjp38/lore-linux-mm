Received: from frodo.biederman.org (IDENT:root@frodo [10.0.0.2])
	by flinx.biederman.org (8.9.3/8.9.3) with ESMTP id KAA01798
	for <linux-mm@kvack.org>; Fri, 26 Jan 2001 10:19:02 -0700
Subject: Re: ioremap_nocache problem?
References: <3A6D5D28.C132D416@sangate.com> <20010123165117Z131182-221+34@kanga.kvack.org> <20010123165117Z131182-221+34@kanga.kvack.org> <20010125155345Z131181-221+38@kanga.kvack.org> <20010125165001Z132264-460+11@vger.kernel.org> <E14LpvQ-0008Pw-00@mail.valinux.com> <20010125175027Z131219-222+40@kanga.kvack.org>
From: ebiederm@xmission.com (Eric W. Biederman)
Date: 26 Jan 2001 09:32:58 -0700
In-Reply-To: Timur Tabi's message of "Thu, 25 Jan 2001 11:53:01 -0600"
Message-ID: <m1itn2e0jp.fsf@frodo.biederman.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Timur Tabi <ttabi@interactivesi.com> writes:

> ** Reply to message from Jeff Hartmann <jhartmann@valinux.com> on Thu, 25 Jan
> 2001 10:47:13 -0700
> 
> 
> > As in an MMIO aperture?  If its MMIO on the bus you should be able to 
> > just call ioremap with the bus address.  By nature of it being outside 
> > of real ram, it should automatically be uncached (unless you've set an 
> > MTRR over that region saying otherwise).
> 
> It's not outside of real RAM.  The device is inside real RAM (it sits on the
> DIMM itself), but I need to poke through the entire 4GB range to see how it
> responds.

The architecture makes some difference.  If the device is inside of RAM
there are two moderately simple ways on x86 to make it work.
1) set mem=yyy where yyy = real_ram but is smaller than your device.
   make certain your device isn't on any mtrr.
2) Disable SPD on your device.
   Do the setup of the pseudo dimm yourself.

In either case that will leave you with a device on the memory bus,
but for all intents and purposes it is then just an i/o device you can
treat like any other.

Eric
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
