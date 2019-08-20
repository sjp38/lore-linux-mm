Return-Path: <SRS0=/Q+j=WQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 03888C3A589
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 16:56:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C2D9B2087E
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 16:56:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C2D9B2087E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=surriel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5BB0C6B0005; Tue, 20 Aug 2019 12:56:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 544236B0006; Tue, 20 Aug 2019 12:56:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4330E6B0007; Tue, 20 Aug 2019 12:56:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0109.hostedemail.com [216.40.44.109])
	by kanga.kvack.org (Postfix) with ESMTP id 1BE6B6B0005
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 12:56:33 -0400 (EDT)
Received: from smtpin07.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id BC28445BB
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 16:56:32 +0000 (UTC)
X-FDA: 75843409824.07.wave20_1bf89a05b1f1e
X-HE-Tag: wave20_1bf89a05b1f1e
X-Filterd-Recvd-Size: 3854
Received: from shelob.surriel.com (shelob.surriel.com [96.67.55.147])
	by imf11.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 16:56:32 +0000 (UTC)
Received: from imladris.surriel.com ([96.67.55.152])
	by shelob.surriel.com with esmtpsa (TLSv1.2:ECDHE-RSA-AES256-GCM-SHA384:256)
	(Exim 4.92)
	(envelope-from <riel@shelob.surriel.com>)
	id 1i07Qi-0004hb-Uw; Tue, 20 Aug 2019 12:56:21 -0400
Message-ID: <5a765e1bda8ec399a29dbdb195d15faa79c44273.camel@surriel.com>
Subject: Re: [PATCH v2] x86/mm/pti: in pti_clone_pgtable() don't increase
 addr by PUD_SIZE
From: Rik van Riel <riel@surriel.com>
To: Song Liu <songliubraving@fb.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra
 <peterz@infradead.org>,  "linux-kernel@vger.kernel.org"
 <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, 
 Kernel Team <Kernel-team@fb.com>, "stable@vger.kernel.org"
 <stable@vger.kernel.org>, Joerg Roedel <jroedel@suse.de>, Dave Hansen
 <dave.hansen@linux.intel.com>, Andy Lutomirski <luto@kernel.org>
Date: Tue, 20 Aug 2019 12:56:20 -0400
In-Reply-To: <9A7CA4D3-76FB-479B-AC7A-FC3FD03B24DF@fb.com>
References: <20190820075128.2912224-1-songliubraving@fb.com>
	 <20190820100055.GI2332@hirez.programming.kicks-ass.net>
	 <alpine.DEB.2.21.1908201315450.2223@nanos.tec.linutronix.de>
	 <44EA504D-2388-49EF-A807-B9712903B146@fb.com>
	 <d887e9e228440097b666bcd316aabc9827a4b01e.camel@fb.com>
	 <9A7CA4D3-76FB-479B-AC7A-FC3FD03B24DF@fb.com>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-pEXkl0lR3wnHbNuZx5FO"
User-Agent: Evolution 3.30.5 (3.30.5-1.fc29) 
MIME-Version: 1.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--=-pEXkl0lR3wnHbNuZx5FO
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2019-08-20 at 10:00 -0400, Song Liu wrote:
>=20
> From 9ae74cff4faf4710a11cb8da4c4a3f3404bd9fdd Mon Sep 17 00:00:00
> 2001
> From: Song Liu <songliubraving@fb.com>
> Date: Mon, 19 Aug 2019 23:59:47 -0700
> Subject: [PATCH] x86/mm/pti: in pti_clone_pgtable(), increase addr
> properly
>=20
> Before 32-bit support, pti_clone_pmds() always adds PMD_SIZE to addr.
> This behavior changes after the 32-bit support:  pti_clone_pgtable()
> increases addr by PUD_SIZE for pud_none(*pud) case, and increases
> addr by
> PMD_SIZE for pmd_none(*pmd) case. However, this is not accurate
> because
> addr may not be PUD_SIZE/PMD_SIZE aligned.
>=20
> Fix this issue by properly rounding up addr to next PUD_SIZE/PMD_SIZE
> in these two cases.
>=20
> Cc: stable@vger.kernel.org # v4.19+
> Fixes: 16a3fe634f6a ("x86/mm/pti: Clone kernel-image on PTE level for
> 32 bit")
> Signed-off-by: Song Liu <songliubraving@fb.com>
> Cc: Joerg Roedel <jroedel@suse.de>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: Dave Hansen <dave.hansen@linux.intel.com>
> Cc: Andy Lutomirski <luto@kernel.org>
> Cc: Peter Zijlstra <peterz@infradead.org>

This looks like it should do the trick!

Reviewed-by: Rik van Riel <riel@surriel.com>

--=20
All Rights Reversed.

--=-pEXkl0lR3wnHbNuZx5FO
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQEzBAABCAAdFiEEKR73pCCtJ5Xj3yADznnekoTE3oMFAl1cJjQACgkQznnekoTE
3oP2CQf5AbKPnlETNpt54qUIOxEF1nXrAYDVtGeSK8Kss4VQHeyuezQYzNd2Yb64
ESHIJFxoeBzfElljfEsvT3BvYYcFtlyS87iND3pr9WWnQ5nFM/kASzp0fGmBzoTB
diU5pD5yg8fBWbXMAwSzDA57CCogWInsgI6UVjli37Y20F+LDS/duzlslae/sxWB
+hvpy43ewEgbQj/3hRrO7S56ssea8wMkwQrVVRpXzT6bbVGMmt8vRfluDn/hG8Cu
Prrk9i+Y2OuCpBiZ//0WAHLhyG74wh6i4iLzt3bqO9vWlB3LkD+C8MCnZBC22Ovw
9umcCc9SszqbVBoDM4zCCAmQ9Ru0ig==
=Wneu
-----END PGP SIGNATURE-----

--=-pEXkl0lR3wnHbNuZx5FO--


