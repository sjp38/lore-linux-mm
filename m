Subject: Re: [PATCH 06/33] mm: allow PF_MEMALLOC from softirq context
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <200710312149.25296.nickpiggin@yahoo.com.au>
References: <20071030160401.296770000@chello.nl>
	 <200710311451.56747.nickpiggin@yahoo.com.au>
	 <1193827359.27652.129.camel@twins>
	 <200710312149.25296.nickpiggin@yahoo.com.au>
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-oJWUmZ+ktd4FzSg/dIhk"
Date: Wed, 31 Oct 2007 14:06:29 +0100
Message-Id: <1193835989.27652.207.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no
List-ID: <linux-mm.kvack.org>

--=-oJWUmZ+ktd4FzSg/dIhk
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, 2007-10-31 at 21:49 +1100, Nick Piggin wrote:
> On Wednesday 31 October 2007 21:42, Peter Zijlstra wrote:
> > On Wed, 2007-10-31 at 14:51 +1100, Nick Piggin wrote:
> > > On Wednesday 31 October 2007 03:04, Peter Zijlstra wrote:
> > > > Allow PF_MEMALLOC to be set in softirq context. When running softir=
qs
> > > > from a borrowed context save current->flags, ksoftirqd will have it=
s
> > > > own task_struct.
> > >
> > > What's this for? Why would ksoftirqd pick up PF_MEMALLOC? (I guess
> > > that some networking thing must be picking it up in a subsequent patc=
h,
> > > but I'm too lazy to look!)... Again, can you have more of a rationale=
 in
> > > your patch headers, or ref the patch that uses it... thanks
> >
> > Right, I knew I was forgetting something in these changelogs.
> >
> > The network stack does quite a bit of packet processing from softirq
> > context. Once you start swapping over network, some of the packets want
> > to be processed under PF_MEMALLOC.
>=20
> Hmm... what about processing from interrupt context?

=46rom what I could tell that is not done, ISR just fills the skb and
sticks it on an RX queue to be further processed by the softirq.

--=-oJWUmZ+ktd4FzSg/dIhk
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD4DBQBHKH3VXA2jU0ANEf4RAk7BAJj7htMwkY1BLb7w8yuI010D2n0VAJ43nRKw
mB/wjUygrFJLHmS7R+jffA==
=19qz
-----END PGP SIGNATURE-----

--=-oJWUmZ+ktd4FzSg/dIhk--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
