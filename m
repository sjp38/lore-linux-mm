Date: Mon, 3 Jul 2000 17:01:36 +0200
From: Jamie Lokier <lk@tantalophile.demon.co.uk>
Subject: Re: maximum memory limit
Message-ID: <20000703170136.A30511@pcep-jamie.cern.ch>
References: <Pine.LNX.4.10.10002081506290.626-100000@mirkwood.dummy.home> <200007020535.WAA07278@woensel.zeropage.com> <20000703113525.F2699@redhat.com> <20000703153213.B29421@pcep-jamie.cern.ch> <20000703151823.D3284@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20000703151823.D3284@redhat.com>; from sct@redhat.com on Mon, Jul 03, 2000 at 03:18:23PM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Raymond Nijssen <raymond@zeropage.com>, Linux Kernel <linux-kernel@vger.rutgers.edu>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Stephen C. Tweedie wrote:
> > There are lots of custom malloc libraries.  If you're going to teach
> > Glibc something anyway, why not add a new mmap flag?
> 
> Because by the time glibc has been loaded, it's too late!  We need the
> crt0.o stub to load libdl.so lower in memory or we have already
> clobbered the address space irretrievably.

??  /lib/ld-linux.so.2 is loaded by the kernel so you can easily changed
the way it is mapped.  Everything from there on is part of Glibc.

The only exception is statically linked binaries, and they're not going
to switch to a new malloc anyway.

-- Jamie
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
