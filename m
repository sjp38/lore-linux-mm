Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 0E2F26B003D
	for <linux-mm@kvack.org>; Tue, 10 Mar 2009 05:55:35 -0400 (EDT)
Date: Tue, 10 Mar 2009 10:55:23 +0100
From: Pierre Ossman <drzeus@drzeus.cx>
Subject: Re: [Bug 12832] New: kernel leaks a lot of memory
Message-ID: <20090310105523.3dfd4873@mjolnir.ossman.eu>
In-Reply-To: <20090310081917.GA28968@localhost>
References: <bug-12832-27@http.bugzilla.kernel.org/>
	<20090307122452.bf43fbe4.akpm@linux-foundation.org>
	<20090307220055.6f79beb8@mjolnir.ossman.eu>
	<20090309013742.GA11416@localhost>
	<20090309020701.GA381@localhost>
	<20090309084045.2c652fbf@mjolnir.ossman.eu>
	<20090309142241.GA4437@localhost>
	<20090309160216.2048e898@mjolnir.ossman.eu>
	<20090310024135.GA6832@localhost>
	<20090310081917.GA28968@localhost>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1; protocol="application/pgp-signature"; boundary="=_freyr.drzeus.cx-16249-1236678927-0001-2"
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "bugme-daemon@bugzilla.kernel.org" <bugme-daemon@bugzilla.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_freyr.drzeus.cx-16249-1236678927-0001-2
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Tue, 10 Mar 2009 16:19:17 +0800
Wu Fengguang <fengguang.wu@intel.com> wrote:

>=20
> Here is the initial patch and tool for finding the missing pages.
>=20
> In the following example, the pages with no flags set is kind of too
> many (1816MB), but hopefully your missing pages will have PG_reserved
> or other flags set ;-)
>=20
> # ./page-types
> L:locked E:error R:referenced U:uptodate D:dirty L:lru A:active S:slab W:=
writeback x:reclaim B:buddy r:reserved c:swapcache b:swapbacked
> =20

Thanks. I'll have a look in a bit. Right now I'm very close to a
complete bisect. It is just ftrace commits left though, so I'm somewhat
sceptical that it is correct. ftrace isn't even turned on in the
kernels I've been testing.

The remaining commits are ec1bb60bb..6712e299.

Rgds
--=20
     -- Pierre Ossman

  WARNING: This correspondence is being monitored by the
  Swedish government. Make sure your server uses encryption
  for SMTP traffic and consider using PGP for end-to-end
  encryption.

--=_freyr.drzeus.cx-16249-1236678927-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.11 (GNU/Linux)

iEYEARECAAYFAkm2OQ0ACgkQ7b8eESbyJLivvgCg1U2UCz338nPNPh0yyHy92VS6
DUYAoKL7Vp+Y4w1661q6ITEJ8HPI0g9b
=ywcd
-----END PGP SIGNATURE-----

--=_freyr.drzeus.cx-16249-1236678927-0001-2--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
