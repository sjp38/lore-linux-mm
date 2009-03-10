Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id ACE6D6B003D
	for <linux-mm@kvack.org>; Tue, 10 Mar 2009 02:56:19 -0400 (EDT)
Date: Tue, 10 Mar 2009 07:56:05 +0100
From: Pierre Ossman <drzeus@drzeus.cx>
Subject: Re: [Bug 12832] New: kernel leaks a lot of memory
Message-ID: <20090310075605.52b22046@mjolnir.ossman.eu>
In-Reply-To: <20090310024135.GA6832@localhost>
References: <bug-12832-27@http.bugzilla.kernel.org/>
	<20090307122452.bf43fbe4.akpm@linux-foundation.org>
	<20090307220055.6f79beb8@mjolnir.ossman.eu>
	<20090309013742.GA11416@localhost>
	<20090309020701.GA381@localhost>
	<20090309084045.2c652fbf@mjolnir.ossman.eu>
	<20090309142241.GA4437@localhost>
	<20090309160216.2048e898@mjolnir.ossman.eu>
	<20090310024135.GA6832@localhost>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1; protocol="application/pgp-signature"; boundary="=_freyr.drzeus.cx-14861-1236668170-0001-2"
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "bugme-daemon@bugzilla.kernel.org" <bugme-daemon@bugzilla.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_freyr.drzeus.cx-14861-1236668170-0001-2
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Tue, 10 Mar 2009 10:41:35 +0800
Wu Fengguang <fengguang.wu@intel.com> wrote:

>=20
>         pgfault 25624481
>         pgmajfault 2490
>         pgrefill_dma 8144
>         pgrefill_dma32 103508
>         pgsteal_dma 4503
>         pgsteal_dma32 179395
>         pgscan_kswapd_dma 4999
>         pgscan_kswapd_dma32 180546
>         pgscan_direct_dma32 384
>         slabs_scanned 153856
>=20
> The above vmstat numbers are a bit large, maybe it's not a fresh booted s=
ystem?
>=20

Probably not. I just grabbed those stats as it was compiling the next
kernel. It takes two hours, so I'm trying to do as many things in
parallel as once. :/

Rgds
--=20
     -- Pierre Ossman

  WARNING: This correspondence is being monitored by the
  Swedish government. Make sure your server uses encryption
  for SMTP traffic and consider using PGP for end-to-end
  encryption.

--=_freyr.drzeus.cx-14861-1236668170-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.11 (GNU/Linux)

iEYEARECAAYFAkm2DwkACgkQ7b8eESbyJLhKXACeK3wwBiXKpVKTlupM3ndGCPPv
PDgAoMc7t7qqMS0/3a38Lu2c64l0O2T6
=CFE/
-----END PGP SIGNATURE-----

--=_freyr.drzeus.cx-14861-1236668170-0001-2--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
