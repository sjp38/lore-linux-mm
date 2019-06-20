Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 051EEC43613
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 01:05:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C0FAB214AF
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 01:05:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C0FAB214AF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=surriel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5D9006B0005; Wed, 19 Jun 2019 21:05:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 589478E0002; Wed, 19 Jun 2019 21:05:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4C6D38E0001; Wed, 19 Jun 2019 21:05:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2CE856B0005
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 21:05:46 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id s67so1517622qkc.6
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 18:05:46 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:message-id
         :subject:from:to:cc:date:in-reply-to:references:user-agent
         :mime-version:sender;
        bh=oUjehZfMRWOQqE/AhDvwqlU2QrZ/D3/sOJ+N4VrE9k8=;
        b=clkOEIznZGDReY04LYumujGKwPJAOcmbFFeBJvDNxozUtGTlh2TFU7s4ZrFoEZ9lFy
         5sRfRSnC7hPmSh0aFNGeL2YMrj164tkpfNnX8/PA8AmM46qwtLQeMYvKH+D8tfjWM5hI
         6sW8pD03/X0vHEGVVq+UJ1rjiO5YtBr7g+ZFK1sjFwgqnEi+Hnyw+Uus8RUodz573NRZ
         ERCQBoGHlAMmAaNU3S4x7MT/7Oyhuk7OMpLnhz0vKHLfj1ultOFmCWFsJeWYwlcq8fCT
         qM+xtlF8HpYka49MGSCcZLWReHrauYX1F4jqy2RUSCCE8S+BwqyrW7UmOMMRRy72eDWg
         KvZg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) smtp.mailfrom=riel@shelob.surriel.com
X-Gm-Message-State: APjAAAV/VGmtkUGEwyJAyb4NfzzA1y8/E2rqa92ReUspRgKAKBElxJMF
	yf3uJJlPxXlKN1B3nOeXEnLvNLitMMeoAM1lfqHw4jbYWbNVlr9T5HtFINyT2EtK3NOZuam4WQ4
	5kFG5WKGE+NYH870YkONh4Aq2NCztNNrEWDehJ3VAPbUfzhYSMknQO3T2nMvDUh3yRA==
X-Received: by 2002:ac8:1b2d:: with SMTP id y42mr58596430qtj.202.1560992745964;
        Wed, 19 Jun 2019 18:05:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyfhZOc9fsiWsY1YVsiX+qZuRC4VkgzWbTx9OFt+N/YUSKWlMpFcoZkWdwIaZUvqYddpdT4
X-Received: by 2002:ac8:1b2d:: with SMTP id y42mr58596390qtj.202.1560992745421;
        Wed, 19 Jun 2019 18:05:45 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560992745; cv=none;
        d=google.com; s=arc-20160816;
        b=0ShWxjJ5tFpAaABsvN9/ss1rZXBXUNS7irbMHsiJ9LKlse2Zxzb1CS2d5ouAMr1eUO
         wnicwVcdmMucmXKpUx/0YDiEar85CJx9T+nSNktohAXEQOApRH8bg/wrUkI9woAJiuhU
         gvEC7LZ8DFkOmUHIUTDbYH4IZjjHPelXaPLt2nmTVgmu8xrztXLpaoGsKRb5TBhzR5tu
         u9BCRhlmwGQnoimIWHE+z1LAZ/z2dlz4hmyp/ksP/bglYzc2aIf8ZFkqL9gUhMqQpcrH
         4z1UexQga5d5aAF2Hpb7dqa0gsZIpBaVnaUQWjVk3bcqkFlijjWRlaL0ND0pwV3KsFJZ
         C+Yw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=sender:mime-version:user-agent:references:in-reply-to:date:cc:to
         :from:subject:message-id;
        bh=oUjehZfMRWOQqE/AhDvwqlU2QrZ/D3/sOJ+N4VrE9k8=;
        b=dXwepHT6K2SgA8Ion6+iWCbNnNXKcdAW1lk0csAykyua2cUTiSlFLZ/24O1gqNtEYL
         0pOpm5YdY4RnAUVCjzxfT/05N8IcZl7YmI6tUJhLEcKTg1WFqGhw+I9nrsxGw6pN1JKn
         SOOSEigXkgjVTJ6tgJpW7h1v4A57VTxEfo3HtNOFF7jNuzF5m5re/eBiQgQ+ZCOSDxJ6
         b2FJ/eKOxZk/arYMFfjVKX+bVpi4ZasF1/9t2gxFXXBIkELLhF83v6cF4Et9jplwMpnB
         sgCHCChViSSvGKSS94ZUMfl0BAjMX8Ipi4QiHmI3VBv1cJTWtlCZreUfaP/4E9QoZOCg
         OYZQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) smtp.mailfrom=riel@shelob.surriel.com
Received: from shelob.surriel.com (shelob.surriel.com. [96.67.55.147])
        by mx.google.com with ESMTPS id e8si3661062qtm.129.2019.06.19.18.05.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jun 2019 18:05:45 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) client-ip=96.67.55.147;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of riel@shelob.surriel.com designates 96.67.55.147 as permitted sender) smtp.mailfrom=riel@shelob.surriel.com
Received: from imladris.surriel.com ([96.67.55.152])
	by shelob.surriel.com with esmtpsa (TLSv1.2:ECDHE-RSA-AES256-GCM-SHA384:256)
	(Exim 4.92)
	(envelope-from <riel@shelob.surriel.com>)
	id 1hdlWK-0002c7-R3; Wed, 19 Jun 2019 21:05:44 -0400
Message-ID: <df3f125197305492c47a825e38ccd8539410d8bd.camel@surriel.com>
Subject: Re: [PATCH v3 4/6] khugepaged: rename collapse_shmem() and
 khugepaged_scan_shmem()
From: Rik van Riel <riel@surriel.com>
To: Song Liu <songliubraving@fb.com>, linux-mm@kvack.org
Cc: matthew.wilcox@oracle.com, kirill.shutemov@linux.intel.com, 
	kernel-team@fb.com, william.kucharski@oracle.com, akpm@linux-foundation.org
Date: Wed, 19 Jun 2019 21:05:44 -0400
In-Reply-To: <20190619062424.3486524-5-songliubraving@fb.com>
References: <20190619062424.3486524-1-songliubraving@fb.com>
	 <20190619062424.3486524-5-songliubraving@fb.com>
Content-Type: multipart/signed; micalg="pgp-sha256";
	protocol="application/pgp-signature"; boundary="=-NyyzcCKld6bokM/woyJB"
User-Agent: Evolution 3.30.5 (3.30.5-1.fc29) 
MIME-Version: 1.0
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--=-NyyzcCKld6bokM/woyJB
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2019-06-18 at 23:24 -0700, Song Liu wrote:
> Next patch will add khugepaged support of non-shmem files. This patch
> renames these two functions to reflect the new functionality:
>=20
>     collapse_shmem()        =3D>  collapse_file()
>     khugepaged_scan_shmem() =3D>  khugepaged_scan_file()
>=20
> Signed-off-by: Song Liu <songliubraving@fb.com>

Acked-by: Rik van Riel <riel@surriel.com>

--=20
All Rights Reversed.

--=-NyyzcCKld6bokM/woyJB
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQEzBAABCAAdFiEEKR73pCCtJ5Xj3yADznnekoTE3oMFAl0K2+gACgkQznnekoTE
3oMK+AgAqoAueKAG8dsvEwNLZOpvVtD59o9tAXccmn+OAyn0HHK2v2rRzticgVCz
W2+ZJ7t98FB3iXUC3FTl4OHxNf5BSPm/oMwxyEBV/92pF0Y2ZOSnm1OC+ZNDKlyV
ak+i0CQFPtp94ylxDjrlDGh1PCEVlOOERDkseCZixdKkKuV/4dSf3o4GswoD0EHJ
IPR1eiN46sIiyWtD0vhyfrZEMwcS8RVuLUPFVDdSVnjcw1j+jggvWe2x8PPsFnpy
/CazyRfLxNL43ZtQ1z1RSVA+cnVnCJLdBsrijQBuyLYkIqSbA5N/8YJ+2iFSfZth
O8P2CTbhw7ffec96eBgRUjOqR19x3Q==
=CEhE
-----END PGP SIGNATURE-----

--=-NyyzcCKld6bokM/woyJB--

