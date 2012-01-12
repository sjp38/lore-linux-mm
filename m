Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id E0B3E6B004F
	for <linux-mm@kvack.org>; Thu, 12 Jan 2012 15:28:10 -0500 (EST)
Received: by iafj26 with SMTP id j26so4264528iaf.14
        for <linux-mm@kvack.org>; Thu, 12 Jan 2012 12:28:10 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAHsXYDCWJSCOe3DkK2kkR4Yvie6WW2DYCi=h_CAwjotwNZWihg@mail.gmail.com>
References: <CAHsXYDCWJSCOe3DkK2kkR4Yvie6WW2DYCi=h_CAwjotwNZWihg@mail.gmail.com>
From: Maxim Kammerer <mk@dee.su>
Date: Thu, 12 Jan 2012 22:27:48 +0200
Message-ID: <CAHsXYDCSCLCBwwDyzfAtW9sHLOkHQAaBxaBWaZ-ws0u7kknWkQ@mail.gmail.com>
Subject: Re: PROBLEM: memtest tests only LOWMEM
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

Hi,

There have been no reply in two weeks. Does it mean that this is the
wrong mailing list for this bug? Or that there is no interest in
fixing it?

Thanks,
Maxim

On Mon, Dec 26, 2011 at 04:18, Maxim Kammerer <mk@dee.su> wrote:
> 1. On 32-bit x86, memtest=3Dn tests only LOWMEM memory (~ 895 MiB),
> HIGHMEM is ignored
>
> 2. On 3.0.4-hardened-r5, HIGHMEM memory (HIGHMEM64G in my tests) is
> apparently ignored during memtest. Looking at arch/x86/mm/memtest.c,
> no special mapping is performed (kmap/kunmap?), so it seems that at
> most ~895 MiB can be tested in 32-bit x86 kernels. This might not
> appear like an important issue (as there are other memory testing
> tools available), but memtest is extremely useful for anti-forensic
> memory wiping on shutdown/reboot in security-oriented distributions
> like Libert=E9 Linux and Tails, and there is no other good substitute.
> See, for instance, some background in Debian bug
> http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=3D646361.
>
> 3. Keywords: memtest, highmem, mm, security
>
> 4. Kernel version: 3.0.4-hardened-r5 (Gentoo) x86 32-bit with PAE

--=20
Maxim Kammerer
Libert=E9 Linux (discussion / support: http://dee.su/liberte-contribute)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
