Subject: Re: 2.5.44-mm2 compile error using gcc 3.2 (gcc 2.96 works fine).
From: Steven Cole <elenstev@mesatop.com>
In-Reply-To: <3DB48BE7.A044FDE0@digeo.com>
References: <3DB46C01.633299F9@digeo.com>
	<1035241430.9472.24.camel@localhost.localdomain>
	<3DB48BE7.A044FDE0@digeo.com>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 21 Oct 2002 20:14:11 -0600
Message-Id: <1035252853.9472.45.camel@localhost.localdomain>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 2002-10-21 at 17:21, Andrew Morton wrote:
> Steven Cole wrote:
> > 
> > ..
> > binutils version is 2.12.90.0.15 for Mandrake 9.0.
> 
> Thanks.
>  
> > BTW, I did a make mrproper on the gcc 3.2 box, retrieved the .config,
> > recompiled, and got the very same "section type conflict" error as
> > before.
> > 
> > After running the gcc 2.96 2.5.44-mm2 for a while longer, I started up
> > dbench and ran some an increasing client load up to 24 clients.  I
> > started a new Konsole in KDE and the system hung, not even responding to
> > pings. That failure was repeatable once, but after those two hangs which
> > required a hard reset, the system was able to run dbench 32 and launch
> > new Konsoles without hanging.  Non-deterministic behavior is so much
> > fun.
> 
> You're on SMP, yes?  Please test with Hugh's "[PATCH] mm mremap freeze"
> patch applied.

I have two machines for testing:

1) SMP box is dual PIII, SCSI, 1GB, RH 7.3 base distro, X not installed.
2) UP  box is PIII, IDE, 256MB, LM 9.0 base distro, X and KDE 3.0.3.

The build failure and lockups were on the UP box.  
The SMP box also ran 2.5.44-mm2 for several hours under load with no
failures.  It was used to successfully build the UP 2.5.44-mm2 kernel.

> 
> But it should have responded to pings even if deadlocked there

Yep, that was weird.  I'm only certain about the first hang when it did
not respond to pings.
.
> 
> Are you using "nmi_watchdog=1"?
> 

Nope.  My understanding is that is only applicable for SMP systems, but
I can add that to the lilo.conf append line if it would do any good on
this troublesome UP box.

Steven

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
