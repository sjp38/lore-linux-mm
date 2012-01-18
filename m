Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx102.postini.com [74.125.245.102])
	by kanga.kvack.org (Postfix) with SMTP id 6998B6B004D
	for <linux-mm@kvack.org>; Wed, 18 Jan 2012 05:18:27 -0500 (EST)
From: Mike Frysinger <vapier@gentoo.org>
Subject: Re: [PATCH v9 3.2 2/9] uprobes: handle breakpoint and signal step exception.
Date: Wed, 18 Jan 2012 05:18:25 -0500
References: <20120110114821.17610.9188.sendpatchset@srdronam.in.ibm.com> <20120118083906.GA4697@bandura.brq.redhat.com> <20120118090232.GE15447@linux.vnet.ibm.com>
In-Reply-To: <20120118090232.GE15447@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1380865.reNDvs1GFv";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Message-Id: <201201180518.31407.vapier@gentoo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Anton Arapov <anton@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Rothwell <sfr@canb.auug.org.au>

--nextPart1380865.reNDvs1GFv
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable

On Wednesday 18 January 2012 04:02:32 Srikar Dronamraju wrote:
> >   Can we use existing SET_IP() instead of set_instruction_pointer() ?
>=20
> Oleg had already commented about this in one his uprobes reviews.
>=20
> The GET_IP/SET_IP available in include/asm-generic/ptrace.h doesnt work
> on all archs. Atleast it doesnt work on powerpc when I tried it.

so migrate the arches you need over to it.

> Also most archs define instruction_pointer(). So I thought (rather Peter
> Zijlstra suggested the name set_instruction_pointer())
> set_instruction_pointer was a better bet than SET_IP. I

asm-generic/ptrace.h already has instruction_pointer_set()

> Also I dont see any usage for SET_IP/GET_IP.

i think you mean "users" here ?  the usage should be fairly obvious.  both=
=20
macros are used by asm-generic/ptrace.h internally, but (currently) rarely=
=20
defined by arches themselves (by design).  the funcs that are based on thes=
e=20
GET/SET helpers though do get used in many places.

simply grep arch/*/include/asm/ptrace.h

> May be we should have something like this in
> include/asm-generic/ptrace.h
>=20
> #ifdef instruction_pointer
> #define GET_IP(regs)		(instruction_pointer(regs))
> #define set_instruction_pointer(regs, val) (instruction_pointer(regs) =3D
> (val))
> #define SET_IP(regs, val)	(set_instruction_pointer(regs,val))
> #endif
>=20

what you propose here won't work on all arches which is the whole point of=
=20
{G,S}ET_IP in the first place.  i proposed a similar idea before and was sh=
ot=20
down for exactly that reason.  look at ia64 for an obvious example.

> or should we do away with GET_IP/SET_IP esp since there are no many
> users?

no, the point is to migrate to asm-generic/ptrace.h, not away from it.
=2Dmike

--nextPart1380865.reNDvs1GFv
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.17 (GNU/Linux)

iQIcBAABAgAGBQJPFpx3AAoJEEFjO5/oN/WBWo8P/2jBRVEnPlphyjM6i9rUoUfg
uYWYpF3S5Br97uESPYzxi3VRQnmPCwggjlaXiL54nx31HCTw2T9mj3rJMga7Dk8V
WOsK7SB0Luvb15SBRQtwkODP4Xn5IYSY5vUcPPc2PQ9KEZFCmygXwutF4DwVUVje
xOIREWU7RP1iYgQ712DZhh5M6Pzm3XbCdOZwhNqzZkEaEYWVjQdYarPbJMzDn6FB
WwGHh8ojnHwlivleLeeJpXAyJV07sHjezOcG/j+n+ldHfyVVhBrv33OPsHftekW5
OstMyX1Dj9JeycwiPzBzaMXiIClr5EJh8sgbSA4A+sV+7+iLKbMr4Hl/1Wt1aFIz
eLrlZfWJ2M1HQ8/TXR30IZhUdwVkV3JzU6g2h8DLzEqIyEq3p1j1xWwcSWACGrmY
rFwC9NcwRHOE+gIQdRhS8Ai9e7jzb39PcpDFtSUKFtU8bf4AfwvyD25TkiDBWBk0
d7ogySDFhScrrAZYnC68Er8rxbLkHH6OXNxWavp8n/iMIDviDaRBpVKMwOiegHKd
NNj2ZI/u7whWX9mzLFgCysLReFMS4GDCOgU3pfl44rbKVEzKe7fFIVE0xXLWdlaD
lpneAKct+V6C2UkazZxwY75TKCEUaRMb4xC9mBgEIQrs/QYfbMxxmtI9MMSTJ30Q
QTi6hK4KTXLL1kTv104W
=O2O6
-----END PGP SIGNATURE-----

--nextPart1380865.reNDvs1GFv--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
