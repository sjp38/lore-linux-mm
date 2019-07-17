Return-Path: <SRS0=+T2N=VO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 78FD1C76192
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 04:38:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3FBBB20818
	for <linux-mm@archiver.kernel.org>; Wed, 17 Jul 2019 04:38:38 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=canb.auug.org.au header.i=@canb.auug.org.au header.b="X5ODQmuV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3FBBB20818
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=canb.auug.org.au
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CC71E6B0008; Wed, 17 Jul 2019 00:38:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C77F68E0006; Wed, 17 Jul 2019 00:38:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B66A68E0005; Wed, 17 Jul 2019 00:38:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8254B6B0008
	for <linux-mm@kvack.org>; Wed, 17 Jul 2019 00:38:37 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id j12so11351695pll.14
        for <linux-mm@kvack.org>; Tue, 16 Jul 2019 21:38:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version;
        bh=alhZetwGpdh94EKu+GRyj6cJ7JxPyjrQX4Mk9dPT0C4=;
        b=VPgtYgvQm0slsv0Sq2Cak9xOUnxCTPPYbG2N2VfSHxews+e5lK1BwgrOEMNtuBFR2o
         cSck1tKbZLpvuEcoIqRfwysCHN6Od6nj4lCxlbYicvNONbnpC/61ymkzUVPKr7FLfXIh
         R379SBxKIfEyl2ziynYItpaNKfyh3YCMfDHYViGHjbVhHh26mlfMUy9GNBjgRyLOQGwu
         cN72mTzCNyxxBQi9rmtYe0+zoV0WCPhhGyIw1Yfe3UZbcYPU9VMg3ODvpyIK7c4ODaLR
         yfB41uQZGsHtJ52704JRjOccHQtGFPGEgQDnBgPeIBl5NdPlFz0WLK/poJnOWwigqPhM
         ajLw==
X-Gm-Message-State: APjAAAV+ulN54jSAODV+MTVygS3TpnmuAZbguvRpFYO6zl80rsRZpfZg
	UtlCF+UvDUjFRt6GTvDU1iaSQNpW8rtUAy29Cpe6hA6KGHEHsaXkXZB2Efhi9H9myyp1ds2MPrH
	9HbjwkqjVL5W/iqFGqqISplFOJ5G+uCjnJqpQwj9svfl6ClBh6CGAyGQKX2YdvwBBsQ==
X-Received: by 2002:a17:902:1e6:: with SMTP id b93mr40231694plb.295.1563338317096;
        Tue, 16 Jul 2019 21:38:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxk1y2H3DF3UdSauAK+6WBVHo0O0VNas7+FBeuc/lquBW/+dLd9CkoyWc4K2VnpAQGZ7Nlr
X-Received: by 2002:a17:902:1e6:: with SMTP id b93mr40231617plb.295.1563338316500;
        Tue, 16 Jul 2019 21:38:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563338316; cv=none;
        d=google.com; s=arc-20160816;
        b=qo8CqUVg6TxZzL2CihUdsMxZgyt6jSo1c+1wtsh8PaPPxLiKAun1BSqFmQ8o8B2Z9n
         kEEoWFU9mjWKRFbgvjgtoEsjSl5xqdjVX3GOp7S93GY/Ojj60eIYFnLzcnAfDvRrCGtQ
         wzqBtSWdHfLZ2yfW6r/iLyloohj3zC3wzoE9Hq4K/w3TL3hVlQiUXpIQ0Y9PHbS3rc+R
         tbP3EOqbhEz2m/X0XGn8WoelYTZtxNpSPRCEt1pjrYPR9YzQfBru6UbuoGlkHWLlH0H/
         5ntudSGEpzdlTz60eQWaZ0NUmrOAEssJx79vFaS2bJTY9/1I+TZYUeAxtxe+HvmVaEGW
         BEkw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:subject:cc:to:from
         :date:dkim-signature;
        bh=alhZetwGpdh94EKu+GRyj6cJ7JxPyjrQX4Mk9dPT0C4=;
        b=ZlimsR+/3Tu1CJL/2M/WmLjA6g7R4/ZgSD1xqUXThLxKRzoGqjcyIdvcftjzF13uYs
         KY2ONqWPBSj0awDc9W0S2+IJwk+ppRVrFkHMrr5XI5M5O4bmiFSbRPR7ly1lV6lhb4O8
         Lls1EoBz4zi3XAEM9jfN9UjTBxp9ebKJ8hrIWVbifoffDqRupSCZY92VFHfogCos/Oxa
         YDNHeBxin297oWvVelEk6kd+5eEN9FwHSbGEsXF0j/lMvu/xfMcsd+yvyU7KYXI7DIe9
         HoBVMGf9KCyieSUk/3MYR0e1amIj5GZtfsfR4LvwKy6wqdJXuXVZgqxEiqiWsoqITgR0
         7p/A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@canb.auug.org.au header.s=201702 header.b=X5ODQmuV;
       spf=pass (google.com: domain of sfr@canb.auug.org.au designates 2401:3900:2:1::2 as permitted sender) smtp.mailfrom=sfr@canb.auug.org.au
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id l102si21648881pje.78.2019.07.16.21.38.36
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 16 Jul 2019 21:38:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of sfr@canb.auug.org.au designates 2401:3900:2:1::2 as permitted sender) client-ip=2401:3900:2:1::2;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@canb.auug.org.au header.s=201702 header.b=X5ODQmuV;
       spf=pass (google.com: domain of sfr@canb.auug.org.au designates 2401:3900:2:1::2 as permitted sender) smtp.mailfrom=sfr@canb.auug.org.au
Received: from authenticated.ozlabs.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (P-256) server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by mail.ozlabs.org (Postfix) with ESMTPSA id 45pPfG6TYLz9s3l;
	Wed, 17 Jul 2019 14:38:30 +1000 (AEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=canb.auug.org.au;
	s=201702; t=1563338311;
	bh=7o9BO0ADmmnMeCw0wqmCaRTFN+ZKwypcAxGKZdpgnH8=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=X5ODQmuVyLfNoIKGCLu+tlRTXrGFI1NzAdzDXi+dNhzYhZ52JAHiH6ajzlN3GeRg+
	 Oh3H2hbICg2tzXiMQQZdmIv42dQDjvuHTUyMtlqc69Vc8yesT0CUZ46RQyfzh4clUd
	 XgeoS0OeA5BkcUogkbmMZGz57c/XmTDI/MBih8AHpPtK4DDNX4jvJqFtz/aZauPbs7
	 VWfrGCAWtflRWAGnrNqLtRAEtDuahMn7MdXBWbus65jHa59P4brEIR5wKDgqSyX6NS
	 Aw1LO7WJ7bWRN2F5kMB+cqyK0zmR6U+/ZTZGPOCdQGa0RZMH8XcEojfGZbuDf8rA3l
	 Ac2SrTUUrLbYg==
Date: Wed, 17 Jul 2019 14:38:30 +1000
From: Stephen Rothwell <sfr@canb.auug.org.au>
To: Randy Dunlap <rdunlap@infradead.org>
Cc: akpm@linux-foundation.org, broonie@kernel.org, mhocko@suse.cz,
 linux-next@vger.kernel.org, linux-fsdevel@vger.kernel.org,
 linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 mm-commits@vger.kernel.org
Subject: Re: mmotm 2019-07-16-17-14 uploaded
Message-ID: <20190717143830.7f7c3097@canb.auug.org.au>
In-Reply-To: <8165e113-6da1-c4c0-69eb-37b2d63ceed9@infradead.org>
References: <20190717001534.83sL1%akpm@linux-foundation.org>
	<8165e113-6da1-c4c0-69eb-37b2d63ceed9@infradead.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/dKk7_zXGQ.uoxSOd_E_Lg0m"; protocol="application/pgp-signature"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--Sig_/dKk7_zXGQ.uoxSOd_E_Lg0m
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi Randy,

On Tue, 16 Jul 2019 20:50:11 -0700 Randy Dunlap <rdunlap@infradead.org> wro=
te:
>
> drivers/gpu/drm/amd/amdgpu/Kconfig contains this (from linux-next.patch):
>=20
> --- a/drivers/gpu/drm/amd/amdgpu/Kconfig~linux-next
> +++ a/drivers/gpu/drm/amd/amdgpu/Kconfig
> @@ -27,7 +27,12 @@ config DRM_AMDGPU_CIK
>  config DRM_AMDGPU_USERPTR
>  	bool "Always enable userptr write support"
>  	depends on DRM_AMDGPU
> +<<<<<<< HEAD
>  	depends on HMM_MIRROR
> +=3D=3D=3D=3D=3D=3D=3D
> +	depends on ARCH_HAS_HMM
> +	select HMM_MIRROR
> +>>>>>>> linux-next/akpm-base =20
>  	help
>  	  This option selects CONFIG_HMM and CONFIG_HMM_MIRROR if it
>  	  isn't already selected to enabled full userptr support.
>=20
> which causes a lot of problems.

Luckily, I don't apply that patch (I instead merge the actual
linux-next tree at that point) so this does not affect the linux-next
included version of mmotm.

--=20
Cheers,
Stephen Rothwell

--Sig_/dKk7_zXGQ.uoxSOd_E_Lg0m
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCAAdFiEENIC96giZ81tWdLgKAVBC80lX0GwFAl0upkYACgkQAVBC80lX
0GxY4Af+Oq4/F8H+zsaZlffvr9kWxLnnkP6seTpuCtjL3Lrao+6kmrHwvRxWXRmb
DqfVHihQ1LhaVW8VoP1GycoXaKBcQn0goSb15YVCUh/GPRhYnatbaUFZwk+ktGmq
k6ln30+yEY2kKT0FzWwX8dovVmwJ1UCQY1D0wCVMItQB58CerSX4mnmZWinA6lfO
NEX3APGd2tviTSbBhvy3O8GsCtLGmyX4WWT+TRWJqOZnHeuPLTsIDjDUCAhab/y6
SY6uOswYK1uKKBRJu7ATwmaJP2DMV2rm6Ueq+XH9Mx/sw19RG2Nji8/EoDhQ1WRh
Yc0S0HXamFnMIevXgk9IgqtFYoCrvA==
=eNFs
-----END PGP SIGNATURE-----

--Sig_/dKk7_zXGQ.uoxSOd_E_Lg0m--

