Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 157A66B004D
	for <linux-mm@kvack.org>; Wed, 18 Jan 2012 06:01:59 -0500 (EST)
From: Mike Frysinger <vapier@gentoo.org>
Subject: Re: [PATCH v9 3.2 2/9] uprobes: handle breakpoint and signal step exception.
Date: Wed, 18 Jan 2012 06:01:58 -0500
References: <20120110114821.17610.9188.sendpatchset@srdronam.in.ibm.com> <201201180518.31407.vapier@gentoo.org> <20120118104749.GG15447@linux.vnet.ibm.com>
In-Reply-To: <20120118104749.GG15447@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart2658957.MnuXhHn6Sl";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Message-Id: <201201180602.04269.vapier@gentoo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Anton Arapov <anton@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Stephen Rothwell <sfr@canb.auug.org.au>

--nextPart2658957.MnuXhHn6Sl
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

On Wednesday 18 January 2012 05:47:49 Srikar Dronamraju wrote:
> > On Wednesday 18 January 2012 04:02:32 Srikar Dronamraju wrote:
> > > >   Can we use existing SET_IP() instead of set_instruction_pointer()=
 ?
> > >=20
> > > Oleg had already commented about this in one his uprobes reviews.
> > >=20
> > > The GET_IP/SET_IP available in include/asm-generic/ptrace.h doesnt wo=
rk
> > > on all archs. Atleast it doesnt work on powerpc when I tried it.
> >=20
> > so migrate the arches you need over to it.
>=20
> One question that could be asked is why arent we using instruction_pointer
> instead of GET_IP since instruction_pointer is being defined in 25
> places and with references in 120 places.

i think you misunderstand the point.  {G,S}ET_IP() is the glue between the=
=20
arch's pt_regs struct and the public facing API.  the only people who shoul=
d=20
be touching those macros are the ptrace core.  instruction_pointer() and=20
instruction_pointer_set() are the API that asm/ptrace.h exports to the rest=
 of=20
the tree.
=2Dmike

--nextPart2658957.MnuXhHn6Sl
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.17 (GNU/Linux)

iQIcBAABAgAGBQJPFqasAAoJEEFjO5/oN/WBT+kP/iZ/l/OJJmqsWS/OGOmAht42
5qtjP2Yci1RXCcAmNYA+yqM2/t9Zdi330FwrsladU/DxIfM80WWhPgsasI4Lt5rR
dfEi47mllDBri8d17WucrAGAtyh+CrqTgIcx4Sg6dhMdCsm80o3kX+J2y/CV/sX7
6swY7TylS/s1IYG3mxNXOmlmOUwOxpHv9Of8MKw1IWUlIXT/kw6nWkCJXE9+MfZS
ya4zDQjMUxU91QZZkP7TdFVZNitUsQgHKLxiwepjLKhFfe+/uVdRN54uDEjxjzox
M8fXkvhhrlT8/YS4tAix4eNCkb34f9vlTsTa1CJR1XwoY7OwvQ0aS3GlxhxJ+a7q
OkpzFwdFIAm3tMsb0BfxAX8I6leeUox3C3H2Yjc3FaFbQIdMJD3OH90XSTeyfwvD
3EPvIUm41npI9Rlb63HAj1Tu5hijbxmSW6scxIgg400JytK76D+hRW32dn0Y8WwC
GP+DRwXfzsUOL7KYi5aNbhfFzaptGGlIyr78K2rGXwxnFbNH/eoOLZLv2uC/XQEe
G7rNLxt954EI/Qf4JgdQK3Fe1rE7EP9v7+7CUvv1sIU7RiqDQPu2Ksa7gE+0jXhv
FUIE9SV8ew8IIF/0WP8a78bJ0Ey0JCroI3CI6Kk1xPLa6wjGbNCEtTiD9+cL5SWn
qMvGM48OVx3LrFL48JZh
=yvLq
-----END PGP SIGNATURE-----

--nextPart2658957.MnuXhHn6Sl--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
