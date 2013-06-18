Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id DBEEE6B0033
	for <linux-mm@kvack.org>; Tue, 18 Jun 2013 11:21:26 -0400 (EDT)
Date: Tue, 18 Jun 2013 10:21:09 -0500
From: Clark Williams <williams@redhat.com>
Subject: Re: [3.11 1/4] slub: Make cpu partial slab support configurable V2
Message-ID: <20130618102109.310f4ce1@riff.lan>
In-Reply-To: <0000013f57a5b278-d9104e1e-ccec-40ec-bd95-f8b0816a38d9-000000@email.amazonses.com>
References: <20130614195500.373711648@linux.com>
	<0000013f44418a14-7abe9784-a481-4c34-8ff3-c3afe2d57979-000000@email.amazonses.com>
	<51BFFFA1.8030402@kernel.org>
	<0000013f57a5b278-d9104e1e-ccec-40ec-bd95-f8b0816a38d9-000000@email.amazonses.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/BOO.H=iBs7EqQKF0+/FIPnl"; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Steven Rostedt <rostedt@goodmis.org>, Thomas Gleixner <tglx@linutronix.de>, Joonsoo Kim <js1304@gmail.com>, Clark Williams <clark@redhat.com>, Glauber Costa <glommer@gmail.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

--Sig_/BOO.H=iBs7EqQKF0+/FIPnl
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Tue, 18 Jun 2013 14:17:25 +0000
Christoph Lameter <cl@linux.com> wrote:

> On Tue, 18 Jun 2013, Pekka Enberg wrote:
>=20
> > The changelog is way too vague. Numbers? Anyone who would want to
> > use this in real world scenarios, please speak up!
>=20
> Steve?

Steve's out this morning so I'll take a stab at it.

This was an RT request. When we switched over to SLUB we saw an
immediate overall performance boost over SLAB but encountered some
249 microsecond latency spikes when testing on large systems
(40-core/256GB RAM). Latency traces showed that our spikes were
SLUB's cpu_partial processing in unfreeze_partials().=20

We hacked up a boot script that would traverse the /sys/kernel/slab
tree and write a zero to all the 'cpu_partial' entries (turning them
off) but asked Christoph if he had a way to configure cpu_partial
processing out, since running the script at boot did not actually catch
all instances of cpu_partial.=20

I'm sure it would be better to actually do cpu_partial processing in
small chunks to avoid latency spikes in latency sensitive applications
but for the short-term it's just easier to turn it off.=20

Clark

--Sig_/BOO.H=iBs7EqQKF0+/FIPnl
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iEYEARECAAYFAlHAeuoACgkQHyuj/+TTEp28PQCgz4BPSZ8AO4bWlfX9uNIkzzKE
9kUAoNvXuImXMopjQCRvXv4IoY5XRrcw
=ltXm
-----END PGP SIGNATURE-----

--Sig_/BOO.H=iBs7EqQKF0+/FIPnl--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
