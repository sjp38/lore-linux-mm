Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 183F76B0006
	for <linux-mm@kvack.org>; Thu, 26 Apr 2018 21:09:34 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id j70so58qka.21
        for <linux-mm@kvack.org>; Thu, 26 Apr 2018 18:09:34 -0700 (PDT)
Received: from shelob.surriel.com (shelob.surriel.com. [96.67.55.147])
        by mx.google.com with ESMTPS id c16-v6si168399qvn.121.2018.04.26.18.09.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Apr 2018 18:09:31 -0700 (PDT)
Message-ID: <1524791357.13490.1.camel@surriel.com>
Subject: Re: [Lsf-pc] [LSF/MM TOPIC NOTES] x86 ZONE_DMA love
From: Rik van Riel <riel@surriel.com>
Date: Thu, 26 Apr 2018 21:09:17 -0400
In-Reply-To: <20180426215406.GB27853@wotan.suse.de>
References: <20180426215406.GB27853@wotan.suse.de>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-bYFiuVr7tqybapqy96A6"
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luis R. Rodriguez" <mcgrof@kernel.org>, linux-mm@kvack.org
Cc: "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>, Jan Kara <jack@suse.cz>, linux-scsi@vger.kernel.org, martin.petersen@oracle.com, matthew@wil.cx, x86@kernel.org, linux-spi@vger.kernel.org, linux-kernel@vger.kernel.org, luto@amacapital.net, broonie@kernel.org, jthumshirn@suse.de, cl@linux.com, mhocko@kernel.org


--=-bYFiuVr7tqybapqy96A6
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2018-04-26 at 21:54 +0000, Luis R. Rodriguez wrote:
> Below are my notes on the ZONE_DMA discussion at LSF/MM 2018. There
> were some
> earlier discussion prior to my arrival to the session about moving
> around
> ZOME_DMA around, if someone has notes on that please share too :)

We took notes during LSF/MM 2018. Not a whole lot
on your topic, but most of the MM and plenary
topics have some notes.

https://etherpad.wikimedia.org/p/LSFMM2018

--=20
All Rights Reversed.
--=-bYFiuVr7tqybapqy96A6
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQEzBAABCAAdFiEEKR73pCCtJ5Xj3yADznnekoTE3oMFAlrieD0ACgkQznnekoTE
3oPs2wf/e3cU+yw6P/o7RotemUv9dEUwBO9xZB7WTlPx9oXdvNGIbfZ/9dnVphKw
R4nnCpwrqDFCz3RWyGcd9pLExcz8wqYzMVFcVJfAzrsVc55SGPXPaN9/Q6qJIyim
4RpsEKrlrpVTJ4eJ/mXs5ExyTPJxQb7LzQHVNLNc0lCzMTf7ScS8s5UTA6rdFFJ6
u+Syxa9HXvf3oaFCogRFfe2gupp7to8+uOS+VqWCfgfiB+1QrgHEyHXFefrA/ZCv
N+Et3YTI+AMLY1Z+HpKgVvze9QvjjyPIEOUp0UaM+y6kHRwhrBX0nimEpMvYWWm8
2kNZ0cQMddPc+h8rH8cQK0maaERb5w==
=CNgl
-----END PGP SIGNATURE-----

--=-bYFiuVr7tqybapqy96A6--
