Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 640E76B005D
	for <linux-mm@kvack.org>; Wed,  5 Sep 2012 08:43:54 -0400 (EDT)
Received: by weys10 with SMTP id s10so541608wey.14
        for <linux-mm@kvack.org>; Wed, 05 Sep 2012 05:43:52 -0700 (PDT)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH 2/2] mm: support MIGRATE_DISCARD
In-Reply-To: <1346832673-12512-2-git-send-email-minchan@kernel.org>
References: <1346832673-12512-1-git-send-email-minchan@kernel.org> <1346832673-12512-2-git-send-email-minchan@kernel.org>
Date: Wed, 05 Sep 2012 14:43:44 +0200
Message-ID: <xa1tmx14prlr.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>

--=-=-=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On Wed, Sep 05 2012, Minchan Kim wrote:
> This patch introudes MIGRATE_DISCARD mode in migration.
> It drops *clean cache pages* instead of migration so that
> migration latency could be reduced by avoiding (memcpy + page remapping).
> It's useful for CMA because latency of migration is very important rather
> than eviction of background processes's workingset. In addition, it needs
> less free pages for migration targets so it could avoid memory reclaiming
> to get free pages, which is another factor increase latency.
>
> Cc: Marek Szyprowski <m.szyprowski@samsung.com>
> Cc: Michal Nazarewicz <mina86@mina86.com>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Mel Gorman <mgorman@suse.de>
> Signed-off-by: Minchan Kim <minchan@kernel.org>

The principle is very good (I always intended for CMA to discard clean
pages but simply did not have time to implement it), and the code looks
reasonably good to me.

--=20
Best regards,                                         _     _
.o. | Liege of Serenely Enlightened Majesty of      o' \,=3D./ `o
..o | Computer Science,  Micha=C5=82 =E2=80=9Cmina86=E2=80=9D Nazarewicz   =
 (o o)
ooo +----<email/xmpp: mpn@google.com>--------------ooO--(_)--Ooo--
--=-=-=
Content-Type: multipart/signed; boundary="==-=-=";
	micalg=pgp-sha1; protocol="application/pgp-signature"

--==-=-=
Content-Type: text/plain


--==-=-=
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)

iQIcBAEBAgAGBQJQR0kBAAoJECBgQBJQdR/0kGsP/2NCgi4lCCoDTDUf98M9ayaE
1yG7CBCBtwkwZ6whTmQiVokBBuhbzXK2+fKzmT5pJin2WS0Yz+A2mBJQM4pIgwf7
QPWYEB6pJ0Y2uS9SkSCAYrxAdkRDXIufhvv9y/tQk24S0ZPNfTdSWSe43H5s5oEP
/GlBX+1Z/7HapE3xOtbFLsQxnREdC3hoolGNhxpoAXp9hQZO4EnFqmd4VQsnoJ7s
w34cPv4Whnjs32wP9ItCRhE0mOfgCixhKNWqKAe46Nb9lAx6NTfdZq/D+E2LB4KF
51tGE/Z3Q4XyZEax8xf0BDIKRGZeIJpq0WzxJlJlkCkihQgvojmGbRCp47Spr6pj
/Cs4rJExHWLrs4YKJu+pxNMLVVxMS0vIforPtMG/WOzSlHdND3jVJBz1SOXVEpN8
O9egq3ObQL7/i29539shdM1ulsrXcmoCNRBVZVsgu2v+a//fct+Ryh0dxfmMdt7X
iPD33G4Nn2V23P5hnWlEiXJwBobEEvxzI3ky9TN7HwFI2vIDddEiP407GVLmLqgY
ZirLXPf7/L0abDnusYP9SWDFDn3fqwHGuWyl1YzhewXerwGG8c7ThJJeZuAcBm9f
m3oOH841SFd31tjUe7VpF8LvAeHhEHyyxO3ERX1q6DiMFutYismi4DsF8Ohvywv5
WluorFV3c6a0DSTyR9uE
=8XOl
-----END PGP SIGNATURE-----
--==-=-=--

--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
