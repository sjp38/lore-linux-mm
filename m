Message-ID: <48A2EE07.3040003@redhat.com>
Date: Wed, 13 Aug 2008 07:21:59 -0700
From: Ulrich Drepper <drepper@redhat.com>
MIME-Version: 1.0
Subject: Re: pthread_create() slow for many threads; also time to revisit
 64b context switch optimization?
References: <af8810200808121736q76640cc1kb814385072fe9b29@mail.gmail.com>	<af8810200808121745h596c175bk348d0aaeeb9bcb45@mail.gmail.com>	<20080813104445.GA24632@elte.hu> <20080813063533.444c650d@infradead.org>
In-Reply-To: <20080813063533.444c650d@infradead.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Arjan van de Ven <arjan@infradead.org>
Cc: Ingo Molnar <mingo@elte.hu>, akpm@linux-foundation.org, hugh@veritas.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, briangrant@google.com, cgd@google.com, mbligh@google.com, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>
List-ID: <linux-mm.kvack.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Arjan van de Ven wrote:
>> i'd go for 1) or 2).
> 
> I would go for 1) clearly; it's the cleanest thing going forward for
> sure.

I want to see numbers first.  If there are problems visible I definitely
would want to see 2.  Andi at the time I wrote that code was very
adamant that I use the flag.

- --
a?? Ulrich Drepper a?? Red Hat, Inc. a?? 444 Castro St a?? Mountain View, CA a??
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)

iEYEARECAAYFAkii7gcACgkQ2ijCOnn/RHTveQCeIefB1R5QpuQ71RNMihKL5oWD
ZVoAnjjjKgXznRx8qtbrF+fgvcNwsngA
=dAz2
-----END PGP SIGNATURE-----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
