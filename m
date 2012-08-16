Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id A53176B005D
	for <linux-mm@kvack.org>; Thu, 16 Aug 2012 09:17:49 -0400 (EDT)
Received: by eeke49 with SMTP id e49so880718eek.14
        for <linux-mm@kvack.org>; Thu, 16 Aug 2012 06:17:48 -0700 (PDT)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [RFC 2/2] cma: support MIGRATE_DISCARD
In-Reply-To: <20120815232023.GA15225@bbox>
References: <1344934627-8473-1-git-send-email-minchan@kernel.org> <1344934627-8473-3-git-send-email-minchan@kernel.org> <xa1t7gt1pnck.fsf@mina86.com> <20120815232023.GA15225@bbox>
Date: Thu, 16 Aug 2012 15:17:40 +0200
Message-ID: <xa1twr0znfgr.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

--=-=-=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

> On Tue, Aug 14, 2012 at 04:19:55PM +0200, Michal Nazarewicz wrote:
>> Since CMA is the only user of MIGRATE_DISCARD it may be worth it to
>> guard it inside an #ifdef, eg:

Minchan Kim <minchan@kernel.org> writes:
> In summary, I want to open it for potential usecases in future if anyone
> doesn't oppose strongly.

Fair enough.

>>>  	if (!trylock_page(page)) {
>>> -		if (!force || mode =3D=3D MIGRATE_ASYNC)
>>> +		if (!force || mode & MIGRATE_ASYNC)

> It's not wrong technically but for readability, NP.

Yep, that was my point, thanks. :)

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

iQIcBAEBAgAGBQJQLPL0AAoJECBgQBJQdR/0GeEP/iRcc7bd6j8GvshNvmU8amgt
Hh0+A/Gb6jygt0ieRQDZcb/qC/ODYLuHQ4NMmns1mXbpswItIvmgBg1pQoblzZo0
3UOsST2EzJm5UtFaLzw4vqoXtUwvI5pQUx+qRtS3ROvZqQeCreRn5au2hWPMhTlY
0bAgFED9KX1rihMp+gn8ega96Lon/0Sdnc+yfQgMFfRl9kXGRauVUrnREO2nMj9o
kg8NM/syC/I/t3D7sL8ifq5mbe2bIOZMCV0o0vbMrpEs1bQaIsOsD5F8+4XG98kH
6vy5oAwqRNnFWjcR5QdG5dp+gcr/OArewDsRX5I49iIB8IuhkJvnfWQtbVVZy98B
ozNdmI5PANN6Kzs7mm0prtHsoiNvY/ODf3UatAK/w5ru+UJW7+SnC0e2pYmjlGhR
Qsrhio5x5geFjSV6iszA54rl313D9mzVSmNONgtKDj06ATAwRpMRErlh6huK32Zu
G5XVIoIXaljlPpOBtT59sEUpmt0FXiX5dCmInIPJkZdXuf4vnibyQlgO126zzoMU
/c7Bjw7RwGgAK3euKJVd69Ro/GS1PIzmfF+Q9+Dk3B/ZyTCEkLeNWxfSf912si4o
BOK4KrM5kjn7gZLYPWxBJ38sU43Oonix6gsaXG8GGCFRhtxQSjayszyH5lDdWl7f
YhSR0kdZ7FICbt9E2kuI
=mflS
-----END PGP SIGNATURE-----
--==-=-=--

--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
