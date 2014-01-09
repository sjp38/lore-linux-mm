Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 2A5586B0031
	for <linux-mm@kvack.org>; Thu,  9 Jan 2014 04:19:52 -0500 (EST)
Received: by mail-wi0-f169.google.com with SMTP id q15so150553wie.2
        for <linux-mm@kvack.org>; Thu, 09 Jan 2014 01:19:51 -0800 (PST)
Received: from mail-wi0-x230.google.com (mail-wi0-x230.google.com [2a00:1450:400c:c05::230])
        by mx.google.com with ESMTPS id b2si2777068wix.13.2014.01.09.01.19.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 09 Jan 2014 01:19:51 -0800 (PST)
Received: by mail-wi0-f176.google.com with SMTP id hq4so6629025wib.9
        for <linux-mm@kvack.org>; Thu, 09 Jan 2014 01:19:51 -0800 (PST)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH 6/7] mm/page_alloc: store freelist migratetype to the page on buddy properly
In-Reply-To: <1389251087-10224-7-git-send-email-iamjoonsoo.kim@lge.com>
References: <1389251087-10224-1-git-send-email-iamjoonsoo.kim@lge.com> <1389251087-10224-7-git-send-email-iamjoonsoo.kim@lge.com>
Date: Thu, 09 Jan 2014 10:19:44 +0100
Message-ID: <xa1t8uupbjgv.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Jiang Liu <jiang.liu@huawei.com>, Mel Gorman <mgorman@suse.de>, Cody P Schafer <cody@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Minchan Kim <minchan@kernel.org>, Andi Kleen <ak@linux.intel.com>, Wei Yongjun <yongjun_wei@trendmicro.com.cn>, Tang Chen <tangchen@cn.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>

--=-=-=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On Thu, Jan 09 2014, Joonsoo Kim wrote:
> To maintain freelist migratetype information on buddy pages, migratetype
> should be set again whenever the page order is changed. set_page_order()
> is the best place to do, because it is called whenever the page order is
> changed, so this patch adds set_buddy_migratetype() to set_page_order().
>
> And this patch makes set/get_buddy_migratetype() only enabled if it is
> really needed, because it has some overhead.
>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Acked-by: Michal Nazarewicz <mina86@mina86.com>


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

iQIcBAEBAgAGBQJSzmmwAAoJECBgQBJQdR/01c4P/Ane1F6g9Fyos/HioQHFOTyT
qElpv05RKxm+fQ6zBraYsXxqtybmVeaxm9CLV3ara5lgyFbRlsWYuLGNeVPrs7P9
4GzdiK1Cd16f6F7ljLQ3SdZO0JgumR0hItG1eV5pR32XGmgZkTPJTfAKBtDNnsO+
QDW6WqNL4GAK5k5m9PGpj9h0RAdQK/FhiiK00rjiPkCm+tqsHw4rJrBusOwUKPrv
rRSsLRUTPhFLXM6EEL6+BrrdZ6ONjCci9Gq6PImIElz2+QTkNg5qcEMHeIE7phLQ
n0LKZ4ojcdTzfRE5vu3w9iCzl8LLlww48HgRcru0faitpNcrs3cVU/h/i4kJ1YWM
gWx2l+qwi30C5Rxlx6Kg9wJq/rBw+ZZSe/HE3ndbsL55JyQhJFSDkD0JR4OSbJ/d
nLNJPsU3u0X5stHeDSfNakc2S/drDvNsR0JOWtLmme2ruUBjz2MrYNWqGDAaYcNf
RkEpln08lsKrNpOdHZK9bUdzVxnADW3nZaJGYu0s1ZNgfg7Ug/CqGg0Mr+uSznW/
YZSeruDxaMFGlckkkwIkYc7IKRz6/wh3jQ2YxPepPOEw5a6uUxIPXoM19EcsKTh+
KL7bEp96FhnH1Us3N/cYLqacRlsIARQVXYx7ydLzsRB5UiKnVu/3pDgJDoGVd29c
ozr6HnxHAPC2a7AaX+js
=CZkg
-----END PGP SIGNATURE-----
--==-=-=--

--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
