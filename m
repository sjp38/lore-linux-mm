Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 7834E6B003D
	for <linux-mm@kvack.org>; Tue, 17 Feb 2009 03:43:37 -0500 (EST)
Date: Tue, 17 Feb 2009 09:43:31 +0100 (CET)
From: Geert Uytterhoeven <Geert.Uytterhoeven@sonycom.com>
Subject: Re: [PATCH] Export symbol ksize()
In-Reply-To: <1234748316.5669.222.camel@calx>
Message-ID: <alpine.LRH.2.00.0902170940430.3391@vixen.sonytel.be>
References: <1234272104-10211-1-git-send-email-kirill@shutemov.name> <84144f020902100535i4d626a9fj8cbb305120cf332a@mail.gmail.com> <20090210134651.GA5115@epbyminw8406h.minsk.epam.com> <Pine.LNX.4.64.0902101605070.20991@melkki.cs.Helsinki.FI>
 <20090212104349.GA13859@gondor.apana.org.au> <1234435521.28812.165.camel@penberg-laptop> <20090212105034.GC13859@gondor.apana.org.au> <1234454104.28812.175.camel@penberg-laptop> <20090215133638.5ef517ac.akpm@linux-foundation.org> <1234734194.5669.176.camel@calx>
 <20090215135555.688ae1a3.akpm@linux-foundation.org> <1234741781.5669.204.camel@calx> <20090215170052.44ee8fd5.akpm@linux-foundation.org> <1234748316.5669.222.camel@calx>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-15
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
To: Matt Mackall <mpm@selenic.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Herbert Xu <herbert@gondor.apana.org.au>, "Kirill A. Shutemov" <kirill@shutemov.name>, Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-crypto@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sun, 15 Feb 2009, Matt Mackall wrote:
> On Sun, 2009-02-15 at 17:00 -0800, Andrew Morton wrote:
> > On Sun, 15 Feb 2009 17:49:41 -0600 Matt Mackall <mpm@selenic.com> wrote:
> 
> > The whole concept is quite hacky and nasty, isn't it?.
> 
> It is, which is part of why we were trying to kill it. The primary users
> were thing growing buffers ala realloc. So we were pushing to change the
> callers to just do a realloc. But IPSEC doesn't fit well into that mold.
> 
> The fundamental problem here for networking is that 1500 is not very
> close to a power of two and just about everything in the VM wants it to
> be. If we could get SKBs fitting more nicely in memory, I think it would
> cease to be a concern.

Does it help to remind that 4 KiB - 2 * 1500 = 1096 \approx 1024?
(hmm, the difference is 72 \approx 64)?

If 1500 is so common as an allocation size, it may make sense to start
special-casing it...

With kind regards,

Geert Uytterhoeven
Software Architect

Sony Techsoft Centre Europe
The Corporate Village . Da Vincilaan 7-D1 . B-1935 Zaventem . Belgium

Phone:    +32 (0)2 700 8453
Fax:      +32 (0)2 700 8622
E-mail:   Geert.Uytterhoeven@sonycom.com
Internet: http://www.sony-europe.com/

A division of Sony Europe (Belgium) N.V.
VAT BE 0413.825.160 . RPR Brussels
Fortis . BIC GEBABEBB . IBAN BE41293037680010

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
