Date: Fri, 10 Dec 1999 00:24:27 +0100 (CET)
From: Ingo Molnar <mingo@chiara.csoma.elte.hu>
Subject: Re: Getting big areas of memory, in 2.3.x?
In-Reply-To: <14416.10643.915336.498552@liveoak.engr.sgi.com>
Message-ID: <Pine.LNX.4.10.9912100021250.10946-100000@chiara.csoma.elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "William J. Earl" <wje@cthulhu.engr.sgi.com>
Cc: Jeff Garzik <jgarzik@mandrakesoft.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Linux Kernel List <linux-kernel@vger.rutgers.edu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 9 Dec 1999, William J. Earl wrote:

> > not at the moment - but it's not really necessery because this is
> > ment for driver initialization time, which usually happens at boot
> > time.

>      That is not the case for loadable (modular) drivers.  Loading st
> as a module, for example, after boot time sometimes works and
> sometimes does not, especially if you set the maximum buffer size
> larger (to, say, 128K, as is needed on some drives for good space
> efficiency).

yep, if eg. an fsck happened before modules are loaded then RAM is filled
up with the buffer-cache. The best guarantee is to compile such drivers
into the kernel.

-- mingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
