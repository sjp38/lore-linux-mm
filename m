Received: from root by main.gmane.org with local (Exim 3.35 #1 (Debian))
	id 18UqsX-0003g6-00
	for <linux-mm@kvack.org>; Sat, 04 Jan 2003 17:10:29 +0100
From: "Steven Barnhart" <sbarn03@softhome.net>
Subject: Re: 2.5.54-mm3
Date: Sat, 04 Jan 2003 10:47:46 -0500
Message-ID: <pan.2003.01.04.15.47.43.915841@softhome.net>
References: <3E16A2B6.A741AE17@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sat, 04 Jan 2003 01:00:38 +0000, Andrew Morton wrote:

> Filesystem mount and unmount is a problem.  Probably, this will not be
> addressed.  People who have specialised latency requirements should avoid
> using automounters and those gadgets which poll CDROMs for insertion events.

That stinks...it don't work in .54 and I'd likem to have my automounter
functioning again. Oh well it *is* 2.5.

> This work has broken the shared pagetable patch - it touches the same code
> in many places.   I shall put Humpty together again, but will not be 
> including it for some time.  This is because there may be bugs in this
> patch series which are accidentally fixed in the shared pagetable patch. So
> shared pagetables will be reintegrated when these changes have had sufficient
> testing.

Also for some reason I always have to do a "touch /fastboot" and boot in
rw mode to boot the kernel. The kernel fails on remouting fs in r-w mode.
X also don't work saying /dev/agpgart don't exist even though it does and
I saw it. agpgart module is loaded..maybe it would work as built into the
kernel? .config attached.

Steven


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
