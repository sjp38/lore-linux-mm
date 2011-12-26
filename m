Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id EC8D46B004F
	for <linux-mm@kvack.org>; Sun, 25 Dec 2011 21:18:50 -0500 (EST)
Received: by obcwo8 with SMTP id wo8so8178514obc.14
        for <linux-mm@kvack.org>; Sun, 25 Dec 2011 18:18:50 -0800 (PST)
MIME-Version: 1.0
From: Maxim Kammerer <mk@dee.su>
Date: Mon, 26 Dec 2011 04:18:29 +0200
Message-ID: <CAHsXYDCWJSCOe3DkK2kkR4Yvie6WW2DYCi=h_CAwjotwNZWihg@mail.gmail.com>
Subject: PROBLEM: memtest tests only LOWMEM
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: tails-dev@boum.org

1. On 32-bit x86, memtest=3Dn tests only LOWMEM memory (~ 895 MiB),
HIGHMEM is ignored

2. On 3.0.4-hardened-r5, HIGHMEM memory (HIGHMEM64G in my tests) is
apparently ignored during memtest. Looking at arch/x86/mm/memtest.c,
no special mapping is performed (kmap/kunmap?), so it seems that at
most ~895 MiB can be tested in 32-bit x86 kernels. This might not
appear like an important issue (as there are other memory testing
tools available), but memtest is extremely useful for anti-forensic
memory wiping on shutdown/reboot in security-oriented distributions
like Libert=E9 Linux and Tails, and there is no other good substitute.
See, for instance, some background in Debian bug
http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=3D646361.

3. Keywords: memtest, highmem, mm, security

4. Kernel version: 3.0.4-hardened-r5 (Gentoo) x86 32-bit with PAE

--=20
Maxim Kammerer
Libert=E9 Linux (discussion / support: http://dee.su/liberte-contribute)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
