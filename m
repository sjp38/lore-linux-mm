Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 18F426B0047
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 02:53:15 -0400 (EDT)
Date: Thu, 12 Mar 2009 07:53:06 +0100
From: Pierre Ossman <drzeus@drzeus.cx>
Subject: Re: [Bug 12832] New: kernel leaks a lot of memory
Message-ID: <20090312075306.41c3f65e@mjolnir.ossman.eu>
In-Reply-To: <20090312114503.43AB.A69D9226@jp.fujitsu.com>
References: <20090311195601.47fe7798@mjolnir.ossman.eu>
	<alpine.DEB.2.00.0903111501070.3062@gandalf.stny.rr.com>
	<20090312114503.43AB.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1; protocol="application/pgp-signature"; boundary="=_freyr.drzeus.cx-6187-1236840789-0001-2"
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Steven Rostedt <rostedt@goodmis.org>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, "bugme-daemon@bugzilla.kernel.org" <bugme-daemon@bugzilla.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_freyr.drzeus.cx-6187-1236840789-0001-2
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Thu, 12 Mar 2009 11:46:31 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

>=20
> Pierre, Could you please operate following command and post result?
>=20
> # cat /sys/devices/system/cpu/possible
>=20

[root@builder ~]# cat /sys/devices/system/cpu/possible
0-15

16 times 11 MB also is the amount of lost memory, so this seems
reasonable.

Rgds
--=20
     -- Pierre Ossman

  WARNING: This correspondence is being monitored by the
  Swedish government. Make sure your server uses encryption
  for SMTP traffic and consider using PGP for end-to-end
  encryption.

--=_freyr.drzeus.cx-6187-1236840789-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.11 (GNU/Linux)

iEYEARECAAYFAkm4sVUACgkQ7b8eESbyJLiIxwCfSHTleByopVL5U3I+yadrRAm0
gmsAn0R1f/mS6qNknwa/SdMSMIu2cShB
=NXR7
-----END PGP SIGNATURE-----

--=_freyr.drzeus.cx-6187-1236840789-0001-2--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
