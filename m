Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 4311C6B004F
	for <linux-mm@kvack.org>; Tue, 11 Aug 2009 02:32:46 -0400 (EDT)
Date: Tue, 11 Aug 2009 08:32:33 +0200
From: Pierre Ossman <drzeus-list@drzeus.cx>
Subject: Re: Page allocation failures in guest
Message-ID: <20090811083233.3b2be444@mjolnir.ossman.eu>
In-Reply-To: <28c262360907130759w29c84117w635b21408090a06c@mail.gmail.com>
References: <20090713115158.0a4892b0@mjolnir.ossman.eu>
	<28c262360907130759w29c84117w635b21408090a06c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1; protocol="application/pgp-signature"; boundary="=_freyr.ossman.eu-24350-1249972359-0001-2"
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: avi@redhat.com, kvm@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Wu Fengguang <fengguang.wu@intel.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_freyr.ossman.eu-24350-1249972359-0001-2
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Mon, 13 Jul 2009 23:59:52 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> On Mon, Jul 13, 2009 at 6:51 PM, Pierre Ossman<drzeus-list@drzeus.cx> wro=
te:
> > Jul 12 23:04:54 loki kernel: Active_anon:14065 active_file:87384 inacti=
ve_anon:37480
> > Jul 12 23:04:54 loki kernel: inactive_file:95821 unevictable:4 dirty:8 =
writeback:0 unstable:0
> > Jul 12 23:04:54 loki kernel: free:1344 slab:7113 mapped:4283 pagetables=
:5656 bounce:0
> > Jul 12 23:04:54 loki kernel: Node 0 DMA free:3988kB min:24kB low:28kB h=
igh:36kB active_anon:0kB inactive_anon:0kB active_file:3532kB inactive_file=
:1032kB unevictable:0kB present:6840kB pages_scanned:0 all_un
>=20
> I don't know why present is bigger than free + [in]active anon ?
> Who know this ?
>=20
> There are 258 pages in inactive file.
> Unfortunately, it seems we don't have any discardable pages.
> The reclaimer can't sync dirty pages to reclaim them, too.
> That's because we are going on GFP_ATOMIC as I mentioned.
>=20

Any ideas here? Is the virtio net driver very GFP_ATOMIC happy so it
drains all those pages? And why is this triggered by a kernel upgrade
in the host?

Avi?

> > reclaimable? no
> > Jul 12 23:04:54 loki kernel: lowmem_reserve[]: 0 994 994 994
> > Jul 12 23:04:54 loki kernel: Node 0 DMA32 free:1388kB min:4020kB low:50=
24kB high:6028kB active_anon:56260kB inactive_anon:149920kB active_file:346=
004kB inactive_file:382252kB unevictable:16kB present:1018016
>=20
>=20
> free : 1388KB min : 4020KB. In addtion, now GFP_HIGH. so calculation
> is as follow for zone_watermark_ok.
>=20
> 1388 < (4020 / 2)
>=20
> So failed it in zone_watermark_ok.
> AFAIU, it's fairy OOM problem.
>=20

I doesn't get out of it though, or at least the virtio net driver
wedges itself.

Rgds
--=20
     -- Pierre Ossman

  WARNING: This correspondence is being monitored by the
  Swedish government. Make sure your server uses encryption
  for SMTP traffic and consider using PGP for end-to-end
  encryption.

--=_freyr.ossman.eu-24350-1249972359-0001-2
Content-Type: application/pgp-signature; name="signature.asc"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.11 (GNU/Linux)

iEYEARECAAYFAkqBEIUACgkQ7b8eESbyJLinNgCgo7iG6a+4J1vk6kps2DmsMsxH
TP8AoLotLqQx1TftH5Zmw5qAfQ979qvt
=g2tv
-----END PGP SIGNATURE-----

--=_freyr.ossman.eu-24350-1249972359-0001-2--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
