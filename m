Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 39B676B005D
	for <linux-mm@kvack.org>; Wed,  5 Sep 2012 08:41:31 -0400 (EDT)
Received: by weys10 with SMTP id s10so540000wey.14
        for <linux-mm@kvack.org>; Wed, 05 Sep 2012 05:41:29 -0700 (PDT)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH 1/2] mm: change enum migrate_mode with bitwise type
In-Reply-To: <1346832673-12512-1-git-send-email-minchan@kernel.org>
References: <1346832673-12512-1-git-send-email-minchan@kernel.org>
Date: Wed, 05 Sep 2012 14:41:21 +0200
Message-ID: <xa1tpq60prpq.fsf@mina86.com>
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
> This patch changes migrate_mode type to bitwise type because
> next patch will add MIGRATE_DISCARD and it could be ORed with other
> attributes so it would be better to change it with bitwise type.
>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Mel Gorman <mgorman@suse.de>
> Suggested-by: Michal Nazarewicz <mina86@mina86.com>
> Signed-off-by: Minchan Kim <minchan@kernel.org>

Acked-by: Michal Nazarewicz <mina86@mina86.com>

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

iQIcBAEBAgAGBQJQR0hxAAoJECBgQBJQdR/0gwwP/RJlbZFdIP6gyyiMI6lP2YFy
QRoG1uUjrQTw74grU6PAkO1C5Lji1X15pQJLcu5lJYPQCEa8AwJLCDa46C8xVZlY
4PFDdMdatFQtcenxK1OsEkmXsWZJWHT8/1KVr+RXhn3N0Z7RCAgcjwCNgb6OgrWo
0g3KuvMLp8jidEPPWKNlWyew7B41dXpwsKdLipf0MCkqJRke1zWBIPE2pkvRFDC5
REemuyN9/FJZEoX6ysVyeXt2X6jm9U5JLPDbnWfxgWBYtV+p8auI70kEy3SguKZo
BY7P54hJYAZx0VjCMEl2D3TdwN6XIGwuxvPLcIn/srm0EI3ka6RX8+iA8IE+wS8g
sAaIBCWdioFey+AKvE8mCyNA2ywXoBByn57OZvvsdQILTJCOX6BAgeasg41+aWor
rH+hWAB7SlN+XxbGPOLLT3TskYh7MuGFo8BgAir2vBnTz4yt1bVw0hFRd6mz4ZSC
AlwvulAWEPqrCnBqI5vlRnS9VIYMIEpycjjcZ1OnxWVg9HJFLqIEHGKRmxxkRaJY
KaNgTlMAtgCU6f2uSftzEzzSRKDNRmgvaJGFmhGg2oaUpAfIqfjYTDlA1q5jsGfw
EFjsJWeZG62QDLkvgiupoLpCSIr8bpXyWkokDKDjPbxSE/MWzVKQ4AS23D663bI+
lIaya+3sywBGB+aEPeOW
=8tXk
-----END PGP SIGNATURE-----
--==-=-=--

--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
