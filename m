Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f72.google.com (mail-qg0-f72.google.com [209.85.192.72])
	by kanga.kvack.org (Postfix) with ESMTP id 84CB46B0005
	for <linux-mm@kvack.org>; Mon, 23 May 2016 14:49:20 -0400 (EDT)
Received: by mail-qg0-f72.google.com with SMTP id k63so104053311qgf.2
        for <linux-mm@kvack.org>; Mon, 23 May 2016 11:49:20 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k5si25508593qke.143.2016.05.23.11.49.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 May 2016 11:49:19 -0700 (PDT)
Message-ID: <1464029349.16365.58.camel@redhat.com>
Subject: Re: [PATCH 3/3] mm, thp: make swapin readahead under down_read of
 mmap_sem
From: Rik van Riel <riel@redhat.com>
Date: Mon, 23 May 2016 14:49:09 -0400
In-Reply-To: <20160523184246.GE32715@dhcp22.suse.cz>
References: <1464023651-19420-1-git-send-email-ebru.akagunduz@gmail.com>
	 <1464023651-19420-4-git-send-email-ebru.akagunduz@gmail.com>
	 <20160523184246.GE32715@dhcp22.suse.cz>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-2S8Xrnv2jDBKk5tnJv6n"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Ebru Akagunduz <ebru.akagunduz@gmail.com>
Cc: linux-mm@kvack.org, hughd@google.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, iamjoonsoo.kim@lge.com, gorcunov@openvz.org, linux-kernel@vger.kernel.org, mgorman@suse.de, rientjes@google.com, vbabka@suse.cz, aneesh.kumar@linux.vnet.ibm.com, hannes@cmpxchg.org, boaz@plexistor.com


--=-2S8Xrnv2jDBKk5tnJv6n
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2016-05-23 at 20:42 +0200, Michal Hocko wrote:
> On Mon 23-05-16 20:14:11, Ebru Akagunduz wrote:
> >=20
> > Currently khugepaged makes swapin readahead under
> > down_write. This patch supplies to make swapin
> > readahead under down_read instead of down_write.
> You are still keeping down_write. Can we do without it altogether?
> Blocking mmap_sem of a remote proces for write is certainly not nice.

Maybe Andrea can explain why khugepaged requires
a down_write of mmap_sem?

If it were possible to have just down_read that
would make the code a lot simpler.

--=20
All Rights Reversed.


--=-2S8Xrnv2jDBKk5tnJv6n
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAABCAAGBQJXQ1CmAAoJEM553pKExN6DrMUH/05e6zsWP2ZtM1UisbmtX31w
+et8QpB8scRtyKvyrCgp/TJHyGpEQuExm4xli2lo35gld+ghdXb1eKzWFi1s66iW
WQKsozVBoMAflRC5TDZf3rQoOfNDkHb9NGzzazRZklNdJl4wZhTUoaJ7hM1m8Wj1
L6wH3XUe3PMlPx7mBhZKj0hZ6GM3AAkaK+LrbjPf/hLP9XDPQMJHDi4hizOM8hCy
4Kid0RX1UFctwu3Pf99Lr/GkIUWZNZocXEzCObZ9s/6cc33ZqNBjoSbjUEX+pW1C
a52bAOfslafFKPeftBdof/HD+Ru5XX6UNAjH6Y4Igt42vNRmdCF9kRlYXH8vrjs=
=1wFg
-----END PGP SIGNATURE-----

--=-2S8Xrnv2jDBKk5tnJv6n--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
