Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-gg0-f169.google.com (mail-gg0-f169.google.com [209.85.161.169])
	by kanga.kvack.org (Postfix) with ESMTP id F1DAA6B0037
	for <linux-mm@kvack.org>; Sat, 21 Dec 2013 20:31:27 -0500 (EST)
Received: by mail-gg0-f169.google.com with SMTP id f4so919181ggn.0
        for <linux-mm@kvack.org>; Sat, 21 Dec 2013 17:31:27 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [2402:b800:7003:1:1::1])
        by mx.google.com with ESMTPS id v3si11837693yhd.13.2013.12.21.17.31.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 21 Dec 2013 17:31:27 -0800 (PST)
Date: Sun, 22 Dec 2013 00:58:19 +1100
From: David Gibson <david@gibson.dropbear.id.au>
Subject: Re: [PATCH v3 03/14] mm, hugetlb: protect region tracking via newly
 introduced resv_map lock
Message-ID: <20131221135819.GB12407@voom.fritz.box>
References: <1387349640-8071-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1387349640-8071-4-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="5I6of5zJg18YgZEa"
Content-Disposition: inline
In-Reply-To: <1387349640-8071-4-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hillf Danton <dhillf@gmail.com>


--5I6of5zJg18YgZEa
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Dec 18, 2013 at 03:53:49PM +0900, Joonsoo Kim wrote:
> There is a race condition if we map a same file on different processes.
> Region tracking is protected by mmap_sem and hugetlb_instantiation_mutex.
> When we do mmap, we don't grab a hugetlb_instantiation_mutex, but,
> grab a mmap_sem. This doesn't prevent other process to modify region
> structure, so it can be modified by two processes concurrently.
>=20
> To solve this, I introduce a lock to resv_map and make region manipulation
> function grab a lock before they do actual work. This makes region
> tracking safe.

It's not clear to me if you're saying there is a list corruption race
bug in the existing code, or only that there will be if the
instantiation mutex goes away.

--=20
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/~dgibson

--5I6of5zJg18YgZEa
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.15 (GNU/Linux)

iQIcBAEBAgAGBQJStZ57AAoJEGw4ysog2bOSBdEQAOaAOMmUK8EGKd1tAgG6wpF9
UydrFqPy5nTreKrDrL3PwTR/EXfoK6+nnH99sh1QR19iPSpkA4sgmzKvHqCfHk31
fBC8ry6Ghc8yyUEVCcSjwZ0UIE9sGFD+9PFB+/uLe+XzsO+bsTOk88AJQ5qyDBP6
7FP1ECjP0DZaBWrLfUpSjZbYy8VWzjwHvLfy78C+syrflfaQ9DQEEtEdTI6ZJpmV
D7gT45jjuLvjuPIzSMk3d73GlkJxTlrNp2r3wF5nq+73i8OmG9MBL/NcvRWmvi59
ZxDTUPf8l34bqg8JdAIbzfRizeAPy1Wi5AXzqNs8eriJN8Esvq2mmtFm/1fTR8Hm
VyKrLoEYN6/N6wcBAZLuwrZNe++OfowUn9+GkCkG7QEGxaMDZlDtzT4Lup8qmRvB
tZlgujwR66m98keYa3a4CFlsnDiyfFiEvXg7Luwf419C4aH5sQlIRkHnxpv8v9Rz
F3BKM/hnQ+VcdYKa0N5BEMCgi3yebtfbtZ0+c0ksMdPfdzUoP8EWc+MkzhbJpzRx
mDOHOPm+nVWWgd3/hG88k/7a4/OEga+fYFaY/8UoJyL34Bi/iSRH/OnekiAi5DNi
Esb5rRmAOCGXuWzK5b7Z2svlWqj56g/KM4fk2yGpuUf68wcGTezBqOuX7LbbX30d
yxsXD8omoGoDjCzs99s/
=AvLd
-----END PGP SIGNATURE-----

--5I6of5zJg18YgZEa--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
