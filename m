Message-ID: <48A303EE.8070002@redhat.com>
Date: Wed, 13 Aug 2008 08:55:26 -0700
From: Ulrich Drepper <drepper@redhat.com>
MIME-Version: 1.0
Subject: Re: pthread_create() slow for many threads; also time to revisit
 64b context switch optimization?
References: <af8810200808121736q76640cc1kb814385072fe9b29@mail.gmail.com> <af8810200808121745h596c175bk348d0aaeeb9bcb45@mail.gmail.com> <20080813104445.GA24632@elte.hu> <20080813063533.444c650d@infradead.org> <48A2EE07.3040003@redhat.com> <20080813142529.GB21129@elte.hu> <48A2F157.7000303@redhat.com> <20080813151007.GA8780@elte.hu> <48A2FC17.9070302@redhat.com> <20080813154043.GA11886@elte.hu>
In-Reply-To: <20080813154043.GA11886@elte.hu>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Arjan van de Ven <arjan@infradead.org>, akpm@linux-foundation.org, hugh@veritas.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, briangrant@google.com, cgd@google.com, mbligh@google.com, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>
List-ID: <linux-mm.kvack.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Ingo Molnar wrote:
> Btw., can you see any problems with option #1: simply removing MAP_32BIT 
> from 64-bit stack allocations in glibc unconditionally?

Yes, as we both agree, there are still such machines out there.

The real problem is: what to do if somebody complains?  If we would have
the extra flag such people could be accommodated.  If there is no such
flag then distributions cannot just add the flag (it's part of the
kernel API) and they would be caught between a rock and a hard place.
Option #2 provides the biggest flexibility.

I upstream kernel truly doesn't care about such machines anymore there
are two options:

- - really do nothing at all

- - at least reserve a flag in case somebody wants/has to implement option
  #2

- --
a?? Ulrich Drepper a?? Red Hat, Inc. a?? 444 Castro St a?? Mountain View, CA a??
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkijA+4ACgkQ2ijCOnn/RHRhLQCdGNvwikwY4hMHBuYUP4WDqsy3
cfcAn2hrN1MoOkN3UIC4iSUCtqD2Yl6W
=yG5T
-----END PGP SIGNATURE-----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
