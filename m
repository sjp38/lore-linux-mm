Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id C45C86B0062
	for <linux-mm@kvack.org>; Thu,  6 Sep 2012 08:51:47 -0400 (EDT)
Received: by wgbdq12 with SMTP id dq12so1316843wgb.26
        for <linux-mm@kvack.org>; Thu, 06 Sep 2012 05:51:46 -0700 (PDT)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [RFC v2] memory-hotplug: remove MIGRATE_ISOLATE from free_area->free_list
In-Reply-To: <5048657A.7060004@cn.fujitsu.com>
References: <1346900018-14759-1-git-send-email-minchan@kernel.org> <50485B7B.3030201@cn.fujitsu.com> <20120906081818.GC16231@bbox> <5048657A.7060004@cn.fujitsu.com>
Date: Thu, 06 Sep 2012 14:51:39 +0200
Message-ID: <xa1tpq5z9uw4.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lai Jiangshan <laijs@cn.fujitsu.com>, Minchan Kim <minchan@kernel.org>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Wen Congyang <wency@cn.fujitsu.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>

--=-=-=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On Thu, Sep 06 2012, Lai Jiangshan wrote:
> +found:
> +	next_pfn =3D page_to_pfn(page);
> +	list_for_each_entry_from(page, &isolated_pages, lru) {
> +		if (page_to_pfn(page) !=3D next_pfn)
> +			return false;
> +		pfn =3D page_to_pfn(page);

+		pfn =3D page_to_pfn(page);
+		if (pfn !=3D next_pfn)
+			return false;

> +		next_pfn =3D pfn + (1UL << page_order(page));
> +		if (next_pfn >=3D end_pfn)
> +			return true;
>  	}

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

iQIcBAEBAgAGBQJQSJxbAAoJECBgQBJQdR/00ygP/RHyhsLlUo9J3kmSwe3GC/Yl
kxh0/b+BGnl5QZMU0FXYDJd9bw18zlM95SkXBGb9rqanr+/aqVrH5bU0Dkt6Yk4S
LmA6Rb8dk0VXGHsesQW3kIKJq1AB4yMUML6618pLYgnPRF4k0D+FmhjdITHfLJoN
husP95zV8xtLtnUXTx3SkcZ5Ae5dA92d6bXOmul6/gA6qB/JZ2xShD474UO0+Dbs
RF2NEYGzMuxEKEMKd4+UTLhgVwkDeTYUEQOyXl3DYvJyJjOACBZ6I4ZwK2xDwK8+
mkS/Y50wxmkS0HwiCdoNcP4Rwpdixy6Mqjj9GBwXZAdMwFZE/hhtvekwquE9UByv
mNz0bfXDVH6kUtzpDfY61cOM+ANEeaoKhnu/ap9g9DR2qAeAmLQgv3YwgaOXwoxT
lnqSMPJVXqpfMFa16VszvS6z501hpW/up+AW6CBRO51cIcYPw13BJ4LF+uDKkttJ
1g4e6NfQ4+LZrNOtNRMUB4AQs8GVli0zSntPAdAyiYanf9ZjdEImq8PTnrKapBAL
RIr1AiX+uJHBSh3yEBs+YAzokwOkWkHKBAQt5PGs1XyWD/IWm3UO9TqquVIxnrMx
f20N6mauE5NERt6dXg8PSoOAol8RBJD0b6jB1iAtoJbXzpwSQF1A+8h+O+xqWK97
JWVHFdiFcojygJw7rzzc
=D1YQ
-----END PGP SIGNATURE-----
--==-=-=--

--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
