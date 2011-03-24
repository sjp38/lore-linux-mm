Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 1736E8D0040
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 05:55:54 -0400 (EDT)
Subject: Re: kmemleak for MIPS
From: Catalin Marinas <catalin.marinas@arm.com>
In-Reply-To: <AANLkTinnqtXf5DE+qxkTyZ9p9Mb8dXai6UxWP2HaHY3D@mail.gmail.com>
References: <9bde694e1003020554p7c8ff3c2o4ae7cb5d501d1ab9@mail.gmail.com>
	 <AANLkTinnqtXf5DE+qxkTyZ9p9Mb8dXai6UxWP2HaHY3D@mail.gmail.com>
Date: Thu, 24 Mar 2011 09:55:40 +0000
Message-ID: <1300960540.32158.13.camel@e102109-lin.cambridge.arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Baluta <dbaluta@ixiacom.com>
Cc: naveen yadav <yad.naveen@gmail.com>, linux-mips@linux-mips.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 2011-03-24 at 09:27 +0000, Daniel Baluta wrote:
> > I want to check kmemleak for both ARM/MIPS. i am able to find kernel
> > patch for ARM at
> > http://linux.derkeiler.com/Mailing-Lists/Kernel/2009-04/msg11830.html.
> > But I could not able to trace patch for MIPS.
>=20
> It seems that kmemleak is not supported on MIPS.
>=20
> According to 'depends on' config entry it is supported on:
> x86, arm, ppc, s390, sparc64, superh, microblaze and tile.
>=20
> C=C4=83t=C4=83lin, can you confirm this? I will send a patch to update
> Documentation/kmemleak.txt.
>=20
> Also, looking forward to work on making kmemleak available on MIPS.

It's not supported probably because no-one tried it, kmemleak is pretty
architecture-independent. You may need to add some standard symbols to
the vmlinux.lds.S if the linker complains and possibly annotate some
false positives if you get any.

Just add "depends on MIPS" and give it a try.

--=20
Catalin


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
