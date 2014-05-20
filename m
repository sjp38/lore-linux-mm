Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 87FF86B0035
	for <linux-mm@kvack.org>; Tue, 20 May 2014 14:15:30 -0400 (EDT)
Received: by mail-pd0-f177.google.com with SMTP id g10so547755pdj.22
        for <linux-mm@kvack.org>; Tue, 20 May 2014 11:15:30 -0700 (PDT)
Received: from mail-pa0-x230.google.com (mail-pa0-x230.google.com [2607:f8b0:400e:c03::230])
        by mx.google.com with ESMTPS id xu2si2850120pbb.129.2014.05.20.11.15.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 20 May 2014 11:15:29 -0700 (PDT)
Received: by mail-pa0-f48.google.com with SMTP id rd3so553130pab.7
        for <linux-mm@kvack.org>; Tue, 20 May 2014 11:15:29 -0700 (PDT)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [RFC][PATCH] CMA: drivers/base/Kconfig: restrict CMA size to non-zero value
In-Reply-To: <537ABD6F.9090608@lge.com>
References: <1399509144-8898-1-git-send-email-iamjoonsoo.kim@lge.com> <1399509144-8898-3-git-send-email-iamjoonsoo.kim@lge.com> <20140513030057.GC32092@bbox> <20140515015301.GA10116@js1304-P5Q-DELUXE> <5375C619.8010501@lge.com> <xa1tppjdfwif.fsf@mina86.com> <537962A0.4090600@lge.com> <20140519055527.GA24099@js1304-P5Q-DELUXE> <xa1td2f91qw5.fsf@mina86.com> <537AA6C7.1040506@lge.com> <xa1tzjiddyrr.fsf@mina86.com> <537ABD6F.9090608@lge.com>
Date: Tue, 20 May 2014 08:15:18 -1000
Message-ID: <xa1t4n0k1fm1.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gioh Kim <gioh.kim@lge.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Minchan Kim <minchan.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Laura Abbott <lauraa@codeaurora.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Heesub Shin <heesub.shin@samsung.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Marek Szyprowski <m.szyprowski@samsung.com>, =?utf-8?B?7J206rG07Zi4?= <gunho.lee@lge.com>, gurugio@gmail.com

--=-=-=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On Mon, May 19 2014, Gioh Kim wrote:
> My point is atomic_pool should be able to work with/without CMA.

Agreed.

>> IMO, cma=3D0 command line argument should be supported, as should having
>> the default CMA size zero.  If CMA size is set to zero, kernel should
>> behave as if CMA was not enabled at compile time.

> It's also good if atomic_pool can work well with zero CMA size.

Exactly.

--=20
Best regards,                                         _     _
.o. | Liege of Serenely Enlightened Majesty of      o' \,=3D./ `o
..o | Computer Science,  Micha=C5=82 =E2=80=9Cmina86=E2=80=9D Nazarewicz   =
 (o o)
ooo +--<mpn@google.com>--<xmpp:mina86@jabber.org>--ooO--(_)--Ooo--

--=-=-=
Content-Type: multipart/signed; boundary="==-=-=";
	micalg=pgp-sha1; protocol="application/pgp-signature"

--==-=-=
Content-Type: text/plain


--==-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIcBAEBAgAGBQJTe5u2AAoJECBgQBJQdR/06jEP/iYmW8mK7Wuu6CYGXh/lzz5t
UFw2wQHHnAzZqAxYVKbgUK+XNFAvZ52jWztebNP7XGFqd8Ryn2btWY1/yJEVm63V
OsIlZ/oiam4J0y6vSUS0gA3MzazQ1dvAIs96MEkKBqrcWE8WQlVxIkbr/EAT1vIH
Zn2Jckhupp4LxRtwtYXXX3P1MikYzIzmsAC2uv4IU4N4btw8e+zSRB06G8PhFZmw
YtkHrI9KVYlK5GkoThILXMYjOmO7dErrGXJc6CSSew/TUgsoHnBme96hG+Ahp5Zq
nakbo2m1On7pCZzwv+OcHKdim6QZWUzDqk1OBruubuCY60u8778FLfVwMIMBCE9w
gFda98xgDUCc40e3UmsZR9kbOiZa8IxRvOdPH3WghS2Vz1BI4IGphH9aBBd6kXbY
osUizgtYA646bpuYsq2++YnxgYiIHvE7sjsdu+GyD7JkbSXBYglejXshuO8QKx4D
eE1Y5Ak643kb//UqZgRCe4VcihYzuHnYjT7rcdfFRzT30+2cMoKhPJULJhIP956I
BOBaM/WQiizDc6vSbpDWjoeC8MoZia2ARqF1vhYFcib1rNaQGpK/MI+tOhx4b0Rc
TqljUnVDUg105PcnSaezDSGN3p4yli8F3BYgECuBr/oHrRObjOL/zFPCKV9XXC5z
HcKJdseWFVuWOU0La7xz
=WbUu
-----END PGP SIGNATURE-----
--==-=-=--

--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
