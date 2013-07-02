Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id B22896B0031
	for <linux-mm@kvack.org>; Tue,  2 Jul 2013 12:53:44 -0400 (EDT)
Date: Tue, 2 Jul 2013 11:53:32 -0500
From: Clark Williams <williams@redhat.com>
Subject: Re: [3.11 1/4] slub: Make cpu partial slab support configurable V2
Message-ID: <20130702115332.4fa8f2db@riff.lan>
In-Reply-To: <0000013fa047b23e-84298a70-911d-43ea-9db3-bc9682bb90b6-000000@email.amazonses.com>
References: <20130614195500.373711648@linux.com>
	<0000013f44418a14-7abe9784-a481-4c34-8ff3-c3afe2d57979-000000@email.amazonses.com>
	<51BFFFA1.8030402@kernel.org>
	<0000013f57a5b278-d9104e1e-ccec-40ec-bd95-f8b0816a38d9-000000@email.amazonses.com>
	<20130618102109.310f4ce1@riff.lan>
	<CAOJsxLHsYVThWL7yKEQaQqxTSpgK8RHm-u8n94t_m4=uMjDqzw@mail.gmail.com>
	<1372170272.18733.201.camel@gandalf.local.home>
	<0000013f9b735739-eb4b29ce-fbc6-4493-ac56-22766da5fdae-000000@email.amazonses.com>
	<20130702100913.0ef4cd25@riff.lan>
	<0000013fa047b23e-84298a70-911d-43ea-9db3-bc9682bb90b6-000000@email.amazonses.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/1nIpdleycquNizPTiAVqWa2"; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Steven Rostedt <rostedt@goodmis.org>, Pekka Enberg <penberg@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Joonsoo Kim <js1304@gmail.com>, Clark Williams <clark@redhat.com>, Glauber Costa <glommer@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>

--Sig_/1nIpdleycquNizPTiAVqWa2
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Tue, 2 Jul 2013 16:47:01 +0000
Christoph Lameter <cl@linux.com> wrote:

> On Tue, 2 Jul 2013, Clark Williams wrote:
>=20
> > What's your recommended method for switching cpu_partial processing
> > off?
> >
> > I'm not all that keen on repeatedly traversing /sys/kernel/slab looking
> > for 'cpu_partial' entries, mainly because if you do it at boot time
> > (i.e. from a startup script) you miss some of the entries.
>=20
> Merge the patch that makes a config option and compile it out of the
> kernel?
>=20

Ah, ok that makes sense. I thought you meant an alternative.

--Sig_/1nIpdleycquNizPTiAVqWa2
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.19 (GNU/Linux)

iEYEARECAAYFAlHTBZAACgkQHyuj/+TTEp2vsACeLE+Sf+TD/xz8MqtpxXg3g/6/
yrYAoL17Kc0fnvzj60g9vtFP37Gpm0bQ
=AHZU
-----END PGP SIGNATURE-----

--Sig_/1nIpdleycquNizPTiAVqWa2--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
