Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 68DB76B004D
	for <linux-mm@kvack.org>; Mon, 21 May 2012 21:10:24 -0400 (EDT)
Date: Tue, 22 May 2012 11:10:07 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: [tip:perf/uprobes] uprobes, mm, x86: Add the ability to install
 and remove uprobes breakpoints
Message-Id: <20120522111007.26f8870307b705f3e09ab36c@canb.auug.org.au>
In-Reply-To: <CA+55aFw5ccuvvtyf6iuuw-Finr79ZkPxgCxL5jNvdnX5oMYkgg@mail.gmail.com>
References: <20120209092642.GE16600@linux.vnet.ibm.com>
	<tip-2b144498350860b6ee9dc57ff27a93ad488de5dc@git.kernel.org>
	<20120521143701.74ab2d0b.akpm@linux-foundation.org>
	<CA+55aFw5ccuvvtyf6iuuw-Finr79ZkPxgCxL5jNvdnX5oMYkgg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Tue__22_May_2012_11_10_07_+1000_1F.Lbx0mFuMra2bl"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, mingo@redhat.com, a.p.zijlstra@chello.nl, peterz@infradead.org, anton@redhat.com, rostedt@goodmis.org, tglx@linutronix.de, oleg@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, hpa@zytor.com, jkenisto@us.ibm.com, andi@firstfloor.org, hch@infradead.org, ananth@in.ibm.com, vda.linux@googlemail.com, masami.hiramatsu.pt@hitachi.com, acme@infradead.org, srikar@linux.vnet.ibm.com, roland@hack.frob.com, mingo@elte.hu, linux-tip-commits@vger.kernel.org

--Signature=_Tue__22_May_2012_11_10_07_+1000_1F.Lbx0mFuMra2bl
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Linus,

On Mon, 21 May 2012 15:00:28 -0700 Linus Torvalds <torvalds@linux-foundatio=
n.org> wrote:
>
> On Mon, May 21, 2012 at 2:37 PM, Andrew Morton
> <akpm@linux-foundation.org> wrote:
> >
> > hm, we seem to have conflicting commits between mainline and linux-next.
> > During the merge window. =C2=A0Again. =C2=A0Nobody knows why this happe=
ns.
>=20
> I didn't have my trivial cleanup branches in linux-next, I'm afraid.
> Usually my pending cleanups are just small patches that I carry along
> without even committing them, this time around I had slightly more
> than that.

You could set up a branch that is merged into linux-next if you want
to ... it may lower the suprise factor.

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/

--Signature=_Tue__22_May_2012_11_10_07_+1000_1F.Lbx0mFuMra2bl
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAEBCAAGBQJPuudvAAoJEECxmPOUX5FESDIP/2gGAQ1hIh7AkJvR5uW8a915
fpvvhpbAIflOcEOWgtWZGuquk4DTed1j8ZmDOwTh1MuY2VIeS7QU1LEcJmunhypD
MElhNShXW4q+o7qqMtBUkbZFrZ4KP6XRw2zHx0Ds8tCblPR5pPiOYuJzx9yWq76V
CofAJVcX9GyeIdnJ+xBOQ73J3ZEJ4fVolMEmzXVKQMJOnJNwmE5ggVreTodLYDAQ
CXBrvA5dvmPsQ1arptLKuqR6RlTgBlz+dKUBL4mcz9q1nj/wUf0f4jrZdqn6/z7F
OzqKSGv20Pt7IujUtuFG0iIJx5lm6Sqk6UpGZKuP9XzED6Q+H79jS6cCjVs/3LmL
6sUlHTxcnrvpLqagM+9mFOJ9nkiykDiHjUpR7d47nfp14EqkcXhJz3NZgdN09FTA
ULf4/IC+BcDn4uuWoFGJrGqdSuL0XciLLNgmqdChF1zAzXzEjEgcJKRZ/XNZ0v9w
Dzb6Er09cWBVpoJAT5G5RDapH90A8uJquUQoSaDf4Mi8PL0eN/1RIq4OiZ2c6sVv
HOhHudmlPPDyTpBcv9gGTt6Eogd/pg13qgxFZgfRqwk943Na7ythgJg66EFNWcrd
y2wk012SJl6vQXmttCrXNJna9kSBsMqdGJLWaloWF+IEy83GCkH+CDK3WX2PfwMV
GQnRw6Vmzix0XgSPpHIC
=Wo4R
-----END PGP SIGNATURE-----

--Signature=_Tue__22_May_2012_11_10_07_+1000_1F.Lbx0mFuMra2bl--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
