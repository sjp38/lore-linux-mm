Message-ID: <48A3266F.9000908@redhat.com>
Date: Wed, 13 Aug 2008 11:22:39 -0700
From: Ulrich Drepper <drepper@redhat.com>
MIME-Version: 1.0
Subject: Re: pthread_create() slow for many threads; also time to revisit
 64b context switch optimization?
References: <af8810200808121736q76640cc1kb814385072fe9b29@mail.gmail.com>	<af8810200808121745h596c175bk348d0aaeeb9bcb45@mail.gmail.com>	<20080813104445.GA24632@elte.hu>	<20080813063533.444c650d@infradead.org>	<48A2EE07.3040003@redhat.com>	<20080813142529.GB21129@elte.hu>	<48A2F157.7000303@redhat.com>	<20080813151007.GA8780@elte.hu>	<48A2FC17.9070302@redhat.com>	<20080813154043.GA11886@elte.hu>	<48A303EE.8070002@redhat.com>	<alpine.LFD.1.10.0808131007530.3462@nehalem.linux-foundation.org>	<48A3222D.2060809@redhat.com> <20080813111635.657febc0@infradead.org>
In-Reply-To: <20080813111635.657febc0@infradead.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Arjan van de Ven <arjan@infradead.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, hugh@veritas.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, briangrant@google.com, cgd@google.com, mbligh@google.com, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>
List-ID: <linux-mm.kvack.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Arjan van de Ven wrote:
> yeah maybe we should also tell it we expect it to be used downwards.
> Oh wait.. MAP_GROWSDOWN ?

MAP_GROWSDOWN is unusable because we have to allocate the entire address
range for the stack.  Otherwise some other allocation happens in that
range and all of a sudden the stack cannot grow as much as needed anymore.

These flags really can be removed.  They should not be used because they
are outright dangerous.

- --
a?? Ulrich Drepper a?? Red Hat, Inc. a?? 444 Castro St a?? Mountain View, CA a??
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkijJm8ACgkQ2ijCOnn/RHQ7/wCfcrLJPlKmtY5AC3c+fuX9LGe8
+YwAnRqLCdSQvwOUdsAz8Hq9H3dmnqEA
=BKsz
-----END PGP SIGNATURE-----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
