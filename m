From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199911022156.NAA15762@google.engr.sgi.com>
Subject: Re: [PATCH] kanoj-mm21-2.3.23 alow larger sizes to shmget()
Date: Tue, 2 Nov 1999 13:56:35 -0800 (PST)
In-Reply-To: <qww1za8in4z.fsf@sap.com> from "Christoph Rohland" at Nov 2, 99 10:45:00 pm
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Rohland <hans-christoph.rohland@sap.com>
Cc: torvalds@transmeta.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> > The clean up code is similar to what I posted at
> > 
> > 	http://humbolt.geo.uu.nl/lists/linux-mm/1999-06/msg00071.html 
> > 
> > previously. Although, I would point out that SHMMAX probably belongs
> > to the asm/* header file (specially, with the size_t size parameter
> > to shmget()).
> 
> Why should we make it arch dependend if we can tune it at runtime?
>

Probably 95% of people who run Linux have no idea what /proc/sys/kernel/shmmax
is, and end up recompiling the kernel with a bumped up SHMMAX, if they find 
SHMMAX too low for their app. On sparc64/alpha and yet to come mips64/ia64, 
SHMMAX can be pretty huge, compared to the ia32 0x2000000. Think out
of the box, and you will see that keeping SHMMAX asm dependent will work 
better for most people ...

Kanoj
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
