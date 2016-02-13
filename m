Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f178.google.com (mail-ig0-f178.google.com [209.85.213.178])
	by kanga.kvack.org (Postfix) with ESMTP id B256F6B0254
	for <linux-mm@kvack.org>; Sat, 13 Feb 2016 06:13:08 -0500 (EST)
Received: by mail-ig0-f178.google.com with SMTP id xg9so25288560igb.1
        for <linux-mm@kvack.org>; Sat, 13 Feb 2016 03:13:08 -0800 (PST)
Received: from out1-smtp.messagingengine.com (out1-smtp.messagingengine.com. [66.111.4.25])
        by mx.google.com with ESMTPS id h70si27127946ioh.15.2016.02.13.03.13.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 13 Feb 2016 03:13:07 -0800 (PST)
Received: from compute2.internal (compute2.nyi.internal [10.202.2.42])
	by mailout.nyi.internal (Postfix) with ESMTP id 7B454202A5
	for <linux-mm@kvack.org>; Sat, 13 Feb 2016 06:13:05 -0500 (EST)
Subject: Re: [net-next PATCH V2 0/3] net: mitigating kmem_cache free slowpath
References: <20160207.142526.1252110536030712971.davem@davemloft.net>
 <20160208121328.8860.67014.stgit@localhost>
From: Tilman Schmidt <tilman@imap.cc>
Message-ID: <56BF0FB6.5050905@imap.cc>
Date: Sat, 13 Feb 2016 12:12:54 +0100
MIME-Version: 1.0
In-Reply-To: <20160208121328.8860.67014.stgit@localhost>
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="xdXKd8MFNvl4kEeswtWbASbqC5ffCcIIa"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: netdev@vger.kernel.org, Jeff Kirsher <jeffrey.t.kirsher@intel.com>, Andrew Morton <akpm@linux-foundation.org>, tom@herbertland.com, Alexander Duyck <alexander.duyck@gmail.com>, alexei.starovoitov@gmail.com, linux-mm@kvack.org, Christoph Lameter <cl@linux.com>, "David S. Miller" <davem@davemloft.net>

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--xdXKd8MFNvl4kEeswtWbASbqC5ffCcIIa
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Hi Jesper,

Am 08.02.2016 um 13:14 schrieb Jesper Dangaard Brouer:
> Introduce new API napi_consume_skb(), that hides/handles bulk freeing
> for the caller.  The drivers simply need to use this call when freeing
> SKBs in NAPI context, e.g. replacing their calles to dev_kfree_skb() /
> dev_consume_skb_any().

Would you mind adding a kerneldoc comment for the new API function?

Thanks,
Tilman

--=20
Tilman Schmidt                              E-Mail: tilman@imap.cc
Bonn, Germany
Nous, on a des fleurs et des bougies pour nous prot=C3=A9ger.


--xdXKd8MFNvl4kEeswtWbASbqC5ffCcIIa
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQEcBAEBCAAGBQJWvw/AAAoJEFPuqx0v+F+qs2gH/3Gr24ChcMolB8Yjjzf8Q/Vx
TSuaNglOS/fapAY3IF0imBDUxeEMNxnUIR3DQFF/SY83GwNpBGCzz+4Saf35vCGp
w77X55DlN4yWEgUctwu/2DxYw2cmb26pA2kBSHTseY6sqeuL1IobNHc6q7B4uda8
NP1+TOpT75KkzBWPaAKcOG01udCYXH469DYKoEhP1wlCN8klPXrvoCBs+1v1wMJE
J8q6LhvtWnDNUJf3SOQLCkwRhENxVFR0gvo2sDPZBgb4lVoE50/FNiRMIb/2eIow
IYvpcunL/E1WdxVK0GnoU4V62bSQGUM8YFZQVOyadPJ7IGUgt+3lU7W9eCuI654=
=X/MR
-----END PGP SIGNATURE-----

--xdXKd8MFNvl4kEeswtWbASbqC5ffCcIIa--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
