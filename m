Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id F268E6B004D
	for <linux-mm@kvack.org>; Tue, 10 Mar 2009 16:21:31 -0400 (EDT)
Date: Tue, 10 Mar 2009 21:21:18 +0100
From: Pierre Ossman <drzeus@drzeus.cx>
Subject: Re: [Bug 12832] New: kernel leaks a lot of memory
Message-ID: <20090310212118.7bf17af6@mjolnir.ossman.eu>
In-Reply-To: <20090310131155.GA9654@localhost>
References: <20090307220055.6f79beb8@mjolnir.ossman.eu>
	<20090309013742.GA11416@localhost>
	<20090309020701.GA381@localhost>
	<20090309084045.2c652fbf@mjolnir.ossman.eu>
	<20090309142241.GA4437@localhost>
	<20090309160216.2048e898@mjolnir.ossman.eu>
	<20090310024135.GA6832@localhost>
	<20090310081917.GA28968@localhost>
	<20090310105523.3dfd4873@mjolnir.ossman.eu>
	<20090310122210.GA8415@localhost>
	<20090310131155.GA9654@localhost>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1; protocol="application/pgp-signature"; boundary="=_freyr.drzeus.cx-20822-1236716485-0001-2"
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "bugme-daemon@bugzilla.kernel.org" <bugme-daemon@bugzilla.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_freyr.drzeus.cx-20822-1236716485-0001-2
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Tue, 10 Mar 2009 21:11:55 +0800
Wu Fengguang <fengguang.wu@intel.com> wrote:

> If we run eatmem or the following commands to take up free memory,
> the missing pages will show up :-)
>=20
>         dd if=3D/dev/zero of=3D/tmp/s bs=3D1M count=3D1 seek=3D1024
>         cp /tmp/s /dev/null
>=20

Not here, which now means I've "found" all of my missing 170 MB.

On 2.6.27, when I fill the page cache I still get over 90 MB left in
"noflags":

0x20000	     24394       95  _________________n  noflags

The same thing with 2.6.26 almost completely drains it:

0x20000	      3697       14  _________________n  noflags

Another interesting data point is that those 80 MB always seem to be
the exact same number of pages every boot.

Rgds
--=20
     -- Pierre Ossman

  WARNING: This correspondence is being monitored by the
  Swedish government. Make sure your server uses encryption
  for SMTP traffic and consider using PGP for end-to-end
  encryption.

--=_freyr.drzeus.cx-20822-1236716485-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.11 (GNU/Linux)

iEYEARECAAYFAkm2y8IACgkQ7b8eESbyJLhhMQCfSK1DUFcMTHFEbFsxM9KpYlL/
dRUAoLLCwcv+g0kn17iTDggkE3eLUGII
=hyiC
-----END PGP SIGNATURE-----

--=_freyr.drzeus.cx-20822-1236716485-0001-2--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
