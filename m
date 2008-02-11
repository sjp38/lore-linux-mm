Date: Mon, 11 Feb 2008 11:15:26 -0700
From: Andreas Dilger <adilger@sun.com>
Subject: Re: [sample] mem_notify v6: usage example
In-reply-to: <2f11576a0802090846t7655e988pb1b712696cad1098@mail.gmail.com>
Message-id: <20080211181526.GC3029@webber.adilger.int>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-transfer-encoding: 7BIT
Content-disposition: inline
References: <2f11576a0802090755n123c9b7dh26e0af6a2fef28af@mail.gmail.com>
 <CE520A17-98F2-4A08-82AB-C3D5061616A1@jonmasters.org>
 <2f11576a0802090846t7655e988pb1b712696cad1098@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Jon Masters <jonathan@jonmasters.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Marcelo Tosatti <marcelo@kvack.org>, Daniel Spang <daniel.spang@gmail.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, Pavel Machek <pavel@ucw.cz>, Al Boldi <a1426z@gawab.com>, Zan Lynx <zlynx@acm.org>
List-ID: <linux-mm.kvack.org>

On Feb 10, 2008  01:46 +0900, KOSAKI Motohiro wrote:
> > This really needs to be triggered via a generic kernel event in the
> > final version - I picture glibc having a reservation API and having
> > generic support for freeing such reservations.
> 
> to be honest, I doubt idea of generic reservation framework.
> 
> end up, we hope drop the application cache, not also dataless memory.
> but, automatically drop mechanism only able to drop dataless memory.
> 
> and, many application have own memory management subsystem.
> I afraid to nobody use too complex framework.

Having such notification handled by glibc to free up unused malloc (or
any heap allocations) would be very useful, because even if a program
does "free" there is no guarantee the memory is returned to the kernel.

I think that having a generic reservation framework is too complex, but
hiding the details of /dev/mem_notify from applications is desirable.
A simple wrapper (possibly part of glibc) to return the poll fd, or set
up the signal is enough.

Cheers, Andreas
--
Andreas Dilger
Sr. Staff Engineer, Lustre Group
Sun Microsystems of Canada, Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
