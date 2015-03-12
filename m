Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 98B7C829A3
	for <linux-mm@kvack.org>; Thu, 12 Mar 2015 18:58:33 -0400 (EDT)
Received: by padbj1 with SMTP id bj1so24143502pad.12
        for <linux-mm@kvack.org>; Thu, 12 Mar 2015 15:58:33 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id ta2si451553pab.0.2015.03.12.15.58.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Mar 2015 15:58:32 -0700 (PDT)
Date: Fri, 13 Mar 2015 09:58:24 +1100
From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: Re: mmotm 2015-03-12-15-17 uploaded
Message-ID: <20150313095824.4298267f@canb.auug.org.au>
In-Reply-To: <550210ac.Pr9rP4DS86Wiia6Q%akpm@linux-foundation.org>
References: <550210ac.Pr9rP4DS86Wiia6Q%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/M8jvcG18qH5ZV8_2Wl4FOWo"; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mm-commits@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-next@vger.kernel.org, mhocko@suse.cz

--Sig_/M8jvcG18qH5ZV8_2Wl4FOWo
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On Thu, 12 Mar 2015 15:18:20 -0700 akpm@linux-foundation.org wrote:
>
> * mm-move-memtest-under-mm.patch

This had no From for Subject lines ... I made it

From: Vladimir Murzin <vladimir.murzin@arm.com>
Subject: mm: move memtest under mm

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

--Sig_/M8jvcG18qH5ZV8_2Wl4FOWo
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJVAhoUAAoJEMDTa8Ir7ZwViAAP/ApnXeD2z7N61J4HuMwoP+su
hDRTkKNpeLRCjE6LwtjIdEQcJyEpSCTdnXp1XlmY6ecAEipO849TWZuB8UiNcriR
hIIdp1HwLvwvD1zO/VGS09Jms/QbejEtQhH3fAekhihKFtITz6dQXg/swyLVBkrw
MOtbzTsrGoAvQREBRpNJtwohEIGtma9oDsjUgWPM/xQuCDxOUSALGoI98gU5o4kZ
ByTqWWkMumFxfkuEynY4eGn2aHOqrYstgcRC9lanwvRbadkTt01kSouSRfVoY2lz
irWoa5d5nY3bZ1/0VvRhrHwXidYb8eVn6lpKxqyTpmI0ETWSS6G30XQZawnuRzv4
yuYI8Jjm9Y6T5OrFNxcbXR1gWAQrkKWzmoWT1eXkdytN11AbrHpWcZrYvoh148in
s3OOzQbv4V5KMIvBWKSc+Zr3AK2n/gw4sbKfCVVLVAZ0Tab2HPGYbkNc9OqEYTjX
jqNVfVVmIYzf82sJYL+vT9VmL0o7kRBMh0I+wLB+WrL8j3A2wiSPP68baxxq8/FR
rcdK999KbnzvbCl3rHrW7ipjL6Yynvr8QaiML5CHVF1Y1CkdxtECwXYv+AxHPxmJ
uo9R7+9wZ+FQGuGZFQM9QSeF/UELKpS7PaE8dMi1ndzwU6bnCWUb1Xfw1rghPX8F
+nbsS8R+5KOGKQXQn7S7
=riGL
-----END PGP SIGNATURE-----

--Sig_/M8jvcG18qH5ZV8_2Wl4FOWo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
