Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f53.google.com (mail-qg0-f53.google.com [209.85.192.53])
	by kanga.kvack.org (Postfix) with ESMTP id 32FB1828DF
	for <linux-mm@kvack.org>; Tue, 23 Feb 2016 10:40:07 -0500 (EST)
Received: by mail-qg0-f53.google.com with SMTP id b35so138732344qge.0
        for <linux-mm@kvack.org>; Tue, 23 Feb 2016 07:40:07 -0800 (PST)
Received: from shelob.surriel.com (shelob.surriel.com. [2002:4a5c:3b41:1:216:3eff:fe57:7f4])
        by mx.google.com with ESMTPS id e95si23442737qgd.14.2016.02.23.07.40.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 23 Feb 2016 07:40:05 -0800 (PST)
Message-ID: <1456241996.7716.34.camel@surriel.com>
Subject: Re: [PATCH] mm,vmscan: compact memory from kswapd when lots of
 memory free already
From: Rik van Riel <riel@surriel.com>
Date: Tue, 23 Feb 2016 10:39:56 -0500
In-Reply-To: <56CC23F7.8010709@suse.cz>
References: <20160222225054.1f6ab286@annuminas.surriel.com>
	 <56CC23F7.8010709@suse.cz>
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature";
	boundary="=-/CMF2PcXH/BNIo6zD7Cu"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, hannes@cmpxchg.org, akpm@linux-foundation.org, mgorman@suse.de


--=-/CMF2PcXH/BNIo6zD7Cu
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2016-02-23 at 10:18 +0100, Vlastimil Babka wrote:
> On 02/23/2016 04:50 AM, Rik van Riel wrote:
> > If kswapd is woken up for a higher order allocation, for example
> > from alloc_skb, but the system already has lots of memory free,
> > kswapd_shrink_zone will rightfully decide kswapd should not free
> > any more memory.
> >=20
> > However, at that point kswapd should proceed to compact memory, on
> > behalf of alloc_skb or others.
> >=20
> > Currently kswapd will only compact memory if it first freed memory,
> > leading kswapd to never compact memory when there is already lots
> > of
> > memory free.
> >=20
> > On my home system, that lead to kswapd occasionally using up to 5%
> > CPU time, with many man wakeups from alloc_skb, and kswapd never
> > doing anything to relieve the situation that caused it to be woken
> > up.
>=20
> Hi,
>=20
> I've proposed replacing kswapd compaction with kcompactd, so this
> hunk=C2=A0
> is gone completely in mmotm. This imperfect comparison was indeed one
> of=C2=A0
> the things I've noted, but it's not all:
>=20
> http://marc.info/?l=3Dlinux-kernel&m=3D145493881908394&w=3D2

Never mind my patch, then. Your solution is nicer,
and already in -mm :)

--=20
All Rights Reversed.


--=-/CMF2PcXH/BNIo6zD7Cu
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQEcBAABAgAGBQJWzH1MAAoJEM553pKExN6D+xoIAJZLpKJroJ3tnswYolFQ0KW+
HxeTgvhsmtJ38Q+PqwFtRz9kt5sOWZCDg5tw0vE8KTfq+o7kd6WeCjGWb11G+jqT
b8Ejbk0chKgLKvEEV2rPUP1t2Dlnit1BGQGLQR5nP+cZhnWuHqrUzIcQcLLGo52V
vC0zCKNpEa28+59GK8nXNqyW0VmKrc3mT3sY/82IhZBAX4946pOKQxqyL/OTigKG
kJbr3ZNWvxYj5PSqHk+4c/BrGgdWHKWg+GCVsEODICLf7sn/RIGGc9OpIEEdGwxY
upcdIKq5/U/RYpMqLKm7UYzRzCbW2kQVwlMKbVwpTBhmf5+kYxulLr0bC7ibBIU=
=WYO5
-----END PGP SIGNATURE-----

--=-/CMF2PcXH/BNIo6zD7Cu--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
