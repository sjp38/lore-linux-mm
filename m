Return-Path: <SRS0=RgjX=VG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2F45DC73C50
	for <linux-mm@archiver.kernel.org>; Tue,  9 Jul 2019 15:13:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B01172166E
	for <linux-mm@archiver.kernel.org>; Tue,  9 Jul 2019 15:13:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=sirena.org.uk header.i=@sirena.org.uk header.b="j8fzb9Cu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B01172166E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 153CE8E0052; Tue,  9 Jul 2019 11:13:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 105B08E0032; Tue,  9 Jul 2019 11:13:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F370F8E0052; Tue,  9 Jul 2019 11:13:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id A8AB28E0032
	for <linux-mm@kvack.org>; Tue,  9 Jul 2019 11:13:39 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id v14so9769586wrm.23
        for <linux-mm@kvack.org>; Tue, 09 Jul 2019 08:13:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=QA3KMjVRm27Z/yBIcHSySV/7M7db3yiAsja5A/gEvl4=;
        b=lAfkDp4ZJAJobkr5AZfVIwyflQXYjzyHnl1+IxDwJjGphjcp89/XUlOqDLXc+17VwN
         r/Q6WpFpf4L+pI6FV4aeXFoT4C0pQxo+rySPEt87jR5ku3n5NQTVDwY8cT/yCWDRasJp
         6sDDLeMQy4SewX+Ni8PUcfogWm42HgJlVaV87OCoZRpO47Ie+Y0gV4nU2q8C3hVwUJlj
         wQk3ie02X5L/+PAMESsDmWzoOXdhh+ztK7ZP0VwmNnbotphlBuvzS3hJtdk+1jBAU+C8
         QszRXRlcIw3BQL45fhp34NE8u68DJsGSiCIDja2R7YHRTQlZ2uKANWaxz3f15DmycVP8
         hWOQ==
X-Gm-Message-State: APjAAAXjQdOyfh2BvOsq89ao7BmWDpmZ99/T0wh2Ka5E8mRopOCgQ9WU
	9pPYMIZzw4w8jg8VKuesBr3olgXn5jJiMgv3ws5VPBT5InB4IUbA4nPgN1ocTWu0r+/a45zYYhh
	pgfKOsl4s/xo6hTM4M4q+xZgnwIB+h0nZt+cvWVOJa8OA76U/6bjOtAvTwnW9uTU=
X-Received: by 2002:a5d:4309:: with SMTP id h9mr25053896wrq.221.1562685219186;
        Tue, 09 Jul 2019 08:13:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwXgO852C/7pz6hyFm5mAdx/nS13OfqEKcFyNd+HZ/W0BTkxPAFlslJ3SjTvpu59gw00aM3
X-Received: by 2002:a5d:4309:: with SMTP id h9mr25053832wrq.221.1562685218202;
        Tue, 09 Jul 2019 08:13:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562685218; cv=none;
        d=google.com; s=arc-20160816;
        b=Ml9ygzR7leF/4lpujrbzNNQR6yjXke0FJLYk4k8WdA4fwiNjwJ39KaVj75Vy8XTVJ6
         Uzu8QNpqIbWuAWU9CbEb5f/A+8QeP2GlrBrbo6usJW07Jlmit4rUmsFn9DoIAQwLVcL5
         UX3C0NAvIoWDb8fX3KWkTUXxKDaEkce9YiI4EgvS1htMiQkaUFh745KqOL/Hwbp9R6Qm
         0UnL95n2t/tss3Ti4ncDbBe/U9Ab9WS87AY1pNJBsABNsp2ALNbUg6pZqsukwrr/e2Dt
         i+RSFsQK/k/OlpsLP9H3Br5/tRwYV/ndEEpgM3fTxdFBxlyLdRaIM+bMpHn1ch5a3uYR
         X9kw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=QA3KMjVRm27Z/yBIcHSySV/7M7db3yiAsja5A/gEvl4=;
        b=qOdS/RyJ8GuGM0h3Njn6pxds5mwyloexvHtdBy9j+ZyJ+QTzfze8RtYslLPNUzN98X
         Bap9U/HwPCCL1Mn0R82+Okl4R7dXjHMjzIgCgxLr7C5lFkIdzwavngXQFtH4OdLRhstF
         BX1w+SDDeYz6yZbKZzYCZVyM0SF8DEZyBGF/RanmhQHm7IieTip/AwIN2lv76v8canrY
         ynTI7ea/SrEBTI20Q6Ryet3NBivoOQlubT+P1Eqv4U65tVYpLIXER14c/EL73vSlF/qe
         +bj+XK9AHqFH1BWNkRF/4SEehEnKq5egSRH3HV7R0OaJxKXsdfeTbM8QMRHH5sV8NxCy
         Mw7Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@sirena.org.uk header.s=20170815-heliosphere header.b=j8fzb9Cu;
       spf=pass (google.com: domain of broonie@sirena.co.uk designates 2a01:7e01::f03c:91ff:fed4:a3b6 as permitted sender) smtp.mailfrom=broonie@sirena.co.uk;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from heliosphere.sirena.org.uk (heliosphere.sirena.org.uk. [2a01:7e01::f03c:91ff:fed4:a3b6])
        by mx.google.com with ESMTPS id g13si16064528wru.38.2019.07.09.08.13.38
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 09 Jul 2019 08:13:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of broonie@sirena.co.uk designates 2a01:7e01::f03c:91ff:fed4:a3b6 as permitted sender) client-ip=2a01:7e01::f03c:91ff:fed4:a3b6;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@sirena.org.uk header.s=20170815-heliosphere header.b=j8fzb9Cu;
       spf=pass (google.com: domain of broonie@sirena.co.uk designates 2a01:7e01::f03c:91ff:fed4:a3b6 as permitted sender) smtp.mailfrom=broonie@sirena.co.uk;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=sirena.org.uk; s=20170815-heliosphere; h=In-Reply-To:Content-Type:
	MIME-Version:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=QA3KMjVRm27Z/yBIcHSySV/7M7db3yiAsja5A/gEvl4=; b=j8fzb9CuPBPbVvm/uYU37XSDy
	leO0YTTLD6yKzuYre7oQPNZrl6Mj5qDaHsHhlcJYM/7Hi4CIwnkKn4lkTLEZ5bLNXguTTAhj0et2G
	x0e56AmMuSXjblhwq9X7kzL9zSsq4zE9YM5Q92kPOkZ16bW7NYNECrxUPyaYVNCIpUc1E=;
Received: from [217.140.106.51] (helo=fitzroy.sirena.org.uk)
	by heliosphere.sirena.org.uk with esmtpsa (TLS1.3:ECDHE_RSA_AES_256_GCM_SHA384:256)
	(Exim 4.92)
	(envelope-from <broonie@sirena.co.uk>)
	id 1hkroE-0005fD-RQ; Tue, 09 Jul 2019 15:13:34 +0000
Received: by fitzroy.sirena.org.uk (Postfix, from userid 1000)
	id 9133ED02D72; Tue,  9 Jul 2019 16:13:33 +0100 (BST)
Date: Tue, 9 Jul 2019 16:13:33 +0100
From: Mark Brown <broonie@kernel.org>
To: Lecopzer Chen <lecopzer.chen@mediatek.com>,
	Mark-PK Tsai <Mark-PK.Tsai@mediatek.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Pavel Tatashin <pasha.tatashin@oracle.com>,
	Oscar Salvador <osalvador@suse.de>, Michal Hocko <mhocko@suse.com>,
	Mike Rapoport <rppt@linux.ibm.com>
Cc: kernel-build-reports@lists.linaro.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, linux-next@vger.kernel.org
Subject: Re: next/master build: 230 builds: 3 failed, 227 passed, 391
 warnings (next-20190709)
Message-ID: <20190709151333.GD14859@sirena.co.uk>
References: <5d24a6be.1c69fb81.c03b6.0fc7@mx.google.com>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
	protocol="application/pgp-signature"; boundary="lc9FT7cWel8HagAv"
Content-Disposition: inline
In-Reply-To: <5d24a6be.1c69fb81.c03b6.0fc7@mx.google.com>
X-Cookie: Visit beautiful Vergas, Minnesota.
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


--lc9FT7cWel8HagAv
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Jul 09, 2019 at 07:37:50AM -0700, kernelci.org bot wrote:

Today's -next fails to build tinyconfig on arm64 and x86_64:

> arm64:
>     tinyconfig: (clang-8) FAIL
>     tinyconfig: (gcc-8) FAIL
>=20
> x86_64:
>     tinyconfig: (gcc-8) FAIL

due to:

> tinyconfig (arm64, gcc-8) =E2=80=94 FAIL, 0 errors, 0 warnings, 0 section=
 mismatches
>=20
> Section mismatches:
>     WARNING: vmlinux.o(.meminit.text+0x430): Section mismatch in referenc=
e from the function sparse_buffer_alloc() to the function .init.text:sparse=
_buffer_free()
>     FATAL: modpost: Section mismatches detected.

(same error for all of them, the warning appears non-fatally in
other configs).  This is caused by f13d13caa6ef2 (mm/sparse.c:
fix memory leak of sparsemap_buf in aliged memory) which adds a
reference from the __meminit annotated sparse_buffer_alloc() to
the newly added __init annotated sparse_buffer_free().

--lc9FT7cWel8HagAv
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAABCgAdFiEEreZoqmdXGLWf4p/qJNaLcl1Uh9AFAl0krxwACgkQJNaLcl1U
h9Az4wf+NjXEh83svNGV2ZzFvXQyIX1F5+MZY7+Qec/kz30LoJZXoVpSQ/XOSPZw
4w0AlO9ogCAByTihA7SYdDeWVIbjYtpnBJkPPH9q4cr4pq73gM5VtvPMOwsLnC02
BkikiievlHtZzDDtVZMwN/lBEsMzLPhVzth/od3+b64fG3miWorWXsCZvQP1Ru31
JcqASJSggqba3JnUZsMTDe/eGCOiVezjwqOK33t+Wa+EVMmdqFUYsezamhzJbbQQ
ig7iz36rj8ktEfNZ7FQF/LL+0oWG/SQr2CLB2gRmspC9eGybuMPFjsDvOsDnX3GZ
9Yp3O3IMuXos/PMucVWAU7m76qnCGQ==
=G6YQ
-----END PGP SIGNATURE-----

--lc9FT7cWel8HagAv--

