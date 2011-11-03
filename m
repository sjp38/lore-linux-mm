Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 435CD6B0069
	for <linux-mm@kvack.org>; Thu,  3 Nov 2011 12:49:35 -0400 (EDT)
Message-Id: <4EB2D427020000780005ED64@nat28.tlf.novell.com>
Date: Thu, 03 Nov 2011 16:49:27 +0000
From: "Jan Beulich" <JBeulich@suse.com>
Subject: Re: [GIT PULL] mm: frontswap (for 3.2 window)
References: <b2fa75b6-f49c-4399-ba94-7ddf08d8db6e@default>
In-Reply-To: <b2fa75b6-f49c-4399-ba94-7ddf08d8db6e@default>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Neo Jia <cyclonusj@gmail.com>, levinsasha928@gmail.com, JeremyFitzhardinge <jeremy@goop.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Jonathan Corbet <corbet@lwn.net>, Chris Mason <chris.mason@oracle.com>, Konrad Wilk <konrad.wilk@oracle.com>, ngupta@vflare.org, LKML <linux-kernel@vger.kernel.org>

>>> On 27.10.11 at 20:52, Dan Magenheimer <dan.magenheimer@oracle.com> =
wrote:
> Hi Linus --
>=20
> Frontswap now has FOUR users: Two already merged in-tree (zcache
> and Xen) and two still in development but in public git trees
> (RAMster and KVM).  Frontswap is part 2 of 2 of the core kernel
> changes required to support transcendent memory; part 1 was cleancache
> which you merged at 3.0 (and which now has FIVE users).
>=20
> Frontswap patches have been in linux-next since June 3 (with zero
> changes since Sep 22).  First posted to lkml in June 2009, frontswap=20
> is now at version 11 and has incorporated feedback from a wide range
> of kernel developers.  For a good overview, see
>    http://lwn.net/Articles/454795.
> If further rationale is needed, please see the end of this email
> for more info.
>=20
> SO... Please pull:
>=20
> git://oss.oracle.com/git/djm/tmem.git #tmem
>=20
>...
> Linux kernel distros incorporating frontswap:
> - Oracle UEK 2.6.39 Beta:
>    http://oss.oracle.com/git/?p=3Dlinux-2.6-unbreakable-beta.git;a=3Dsumm=
ary=20
> - OpenSuSE since 11.2 (2009) [see mm/tmem-xen.c]
>    http://kernel.opensuse.org/cgit/kernel/=20

I've been away so I am too far behind to read this entire
very long thread, but wanted to confirm that we've been
carrying an earlier version of this code as indicated above
and it would simplify our kernel maintenance if frontswap
got merged.  So please count me as supporting frontswap.

Thanks, Jan

> - a popular Gentoo distro
>    http://forums.gentoo.org/viewtopic-t-862105.html=20
>=20
> Xen distros supporting Linux guests with frontswap:
> - Xen hypervisor backend since Xen 4.0 (2009)
>    http://www.xen.org/files/Xen_4_0_Datasheet.pdf=20
> - OracleVM since 2.2 (2009)
>    http://twitter.com/#!/Djelibeybi/status/113876514688352256=20
>=20
> Public visibility for frontswap (as part of transcendent memory):
> - presented at OSDI'08, OLS'09, LCA'10, LPC'10, LinuxCon NA 11, Oracle
>   Open World 2011, two LSF/MM Summits (2010,2011), and three
>   Xen Summits (2009,2010,2011)
> - http://lwn.net/Articles/454795 (current overview)
> - http://lwn.net/Articles/386090 (2010)
> - http://lwn.net/Articles/340080 (2009)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
