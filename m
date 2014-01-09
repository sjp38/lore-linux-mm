Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id E0B246B0031
	for <linux-mm@kvack.org>; Thu,  9 Jan 2014 04:06:42 -0500 (EST)
Received: by mail-wi0-f180.google.com with SMTP id hm19so3166574wib.1
        for <linux-mm@kvack.org>; Thu, 09 Jan 2014 01:06:42 -0800 (PST)
Received: from mail-we0-x230.google.com (mail-we0-x230.google.com [2a00:1450:400c:c03::230])
        by mx.google.com with ESMTPS id x6si2200249wib.85.2014.01.09.01.06.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 09 Jan 2014 01:06:42 -0800 (PST)
Received: by mail-we0-f176.google.com with SMTP id p61so2431870wes.21
        for <linux-mm@kvack.org>; Thu, 09 Jan 2014 01:06:41 -0800 (PST)
From: Michal Nazarewicz <mina86@mina86.com>
Subject: Re: [PATCH 0/7] improve robustness on handling migratetype
In-Reply-To: <1389251087-10224-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1389251087-10224-1-git-send-email-iamjoonsoo.kim@lge.com>
Date: Thu, 09 Jan 2014 10:06:34 +0100
Message-ID: <xa1tha9dbk2t.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Jiang Liu <jiang.liu@huawei.com>, Mel Gorman <mgorman@suse.de>, Cody P Schafer <cody@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Minchan Kim <minchan@kernel.org>, Andi Kleen <ak@linux.intel.com>, Wei Yongjun <yongjun_wei@trendmicro.com.cn>, Tang Chen <tangchen@cn.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>

--=-=-=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On Thu, Jan 09 2014, Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
> Third, there is the problem on buddy allocator. It doesn't consider
> migratetype when merging buddy, so pages from cma or isolate region can
> be moved to other migratetype freelist. It makes CMA failed over and over.
> To prevent it, the buddy allocator should consider migratetype if
> CMA/ISOLATE is enabled.

There should never be situation where a CMA page shares a pageblock (or
a max-order page) with a non-CMA page though, so this should never be an
issue.

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

iQIcBAEBAgAGBQJSzmaaAAoJECBgQBJQdR/03rwP/A70MFWvk9Zz81DwMlNFZQTi
jkeQWXQbKlz0Q6W3FPaTZK7nTqIcRQCwfttIGrnvWJOjw9IfLyWNSdzHaI8eQZsB
2Wyw0jUhhv4ARwOSEopst5Z+oeAmeJKHz4meJObdaH+3szfxNZm5wyl0RaNLqDGd
8MsfmnmLbgTNE/l/Fl2lNzGod36T51DMfzgTqVnBO3zK7WU8iAO3jP3y99aoijbZ
TbV3IH12T6heh/bYN9ky/FIxZ9LGI59pr0AvrvHzPEHD3ubE6La/40XCbosjsKif
MGw+2KmgL4/old+Xdtl6fm1hRAvnjpYk6rBVEzBlSZNcbHu5avfYJjcAfgV9sfMS
i9E02AuI3muTPvglCtAUtciBMdDcqbR8DLyJO8SYNqPqSZz4LtVz0pBqkpQyq7Uw
onUiuzlLSYvD7U1v8KfmRmhMkeIvBRGma2ifOoUOMCLIkhbBE0EIFztis/0BcjTf
CyWHDAMDI2ThkyM+aOgygrS0bnnDCHQDHWv3XvColu+Of6gRQL5gU/KyKI0Mau5T
Zh8DQKlX0u0BZ9Kt7HZ44SNrwEDzpf7Ov/KBgZF/Meg/fDnL06KJOMWjWG6jjTLp
1H6mQiqChwyVJ7qS2RoTWtG78sqI/xgBFVGFzogTehypy0UoRB6C64QjfHkg8SIW
SKevhN+2RDwN3u2FDdC5
=9KuD
-----END PGP SIGNATURE-----
--==-=-=--

--=-=-=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
