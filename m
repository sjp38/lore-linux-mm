Return-Path: <SRS0=pjJT=VR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_SANE_1 autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 29A89C7618F
	for <linux-mm@archiver.kernel.org>; Sat, 20 Jul 2019 02:03:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B41E920880
	for <linux-mm@archiver.kernel.org>; Sat, 20 Jul 2019 02:03:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="FxK9AQGw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B41E920880
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1F2726B0005; Fri, 19 Jul 2019 22:03:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 17ED06B0006; Fri, 19 Jul 2019 22:03:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F39608E0001; Fri, 19 Jul 2019 22:03:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id CE2A56B0005
	for <linux-mm@kvack.org>; Fri, 19 Jul 2019 22:03:57 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id b63so25196855ywc.12
        for <linux-mm@kvack.org>; Fri, 19 Jul 2019 19:03:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=K89J2IEPJbk6VmuKgUrqZ1VHo+WQOc0Cte4m7yFZoOE=;
        b=AjEr5eOYRv5M2Er1l1IY8wU3Cd/Z/9zn2l/gayxvvprXYkPR7BMxXf/gcjSwq/RLWV
         tmsrS27BxlJymYv+V7Jb4yjo66Mt1CEHBlsiXVKB1OudFwJBC+H70Y+foFxWS+XL/yJZ
         qCc2z8ghD851DBnMuaOE7dKioHFndBKxvOvRp4MCvI0w5G2ILD/6TGEUHn3CgVJrlaiR
         NISNQtRMEu4B6au6aktIQkIV0VOu2n25hrF2cNEBheGiDvC4G/VDHzcreXPHQQlb9OWg
         w0QV5bEgGIJaQD/Jt3hpL7niVVK5sMDf0YovAalkSECsBwsddwhzTlDgBWZX4k+zGqyi
         QaRQ==
X-Gm-Message-State: APjAAAVOiwGLj9dLjbsdifDNFwKTrHDfzZHWv7W22Gg7/CCd3CqSCLbr
	jog+3zlQiPOoiKnffNPX621JT5/lgzRJaO40R1CTYeuuKXT0zwlUi5MacZO8RriDIAyawxT7I0K
	CbbGFJK9ZnLps6Oh81ygeG7TsU3TYiuvuxWKAbTXTwaAsI6siq4tcMmK17g8JKXFtKg==
X-Received: by 2002:a81:780e:: with SMTP id t14mr32403406ywc.98.1563588237514;
        Fri, 19 Jul 2019 19:03:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwUxsyf8JqIKRxMw30mIjGAJ0omMlCREUAS5IFAmXyNxknV0g+6m14Sq/6KhgZks9THdCJ8
X-Received: by 2002:a81:780e:: with SMTP id t14mr32403375ywc.98.1563588236723;
        Fri, 19 Jul 2019 19:03:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563588236; cv=none;
        d=google.com; s=arc-20160816;
        b=j0PQiW52xDGwbQXAnUMkrWeVQwh4uXRluAhokfSpYYQLMIZdVpTXh55HTLkWpDR8ET
         ZERkJRKz252wh6QWtyV6NuP9a5SmX420AG5ocxk5vANb5xIbwGybGYyuM1x0BdzU3Kpa
         JtIRY+BgYfC6TFUJYv1HWEF7AfID2YjCUe3a4RUW+WSMFIdclkOwfE1d+T8Mi32RzyKD
         ZU9UgvZXgjLp2IU9aClaB6HGbq6QEu8ALT8AJE6Nh/DOE73dn7PiwPan7cLPkOnGXrjc
         UIBU3POBMYeIVeI7HqiXMwvootTNhsltPnLZGj5DbOl3ayIm8GEEQ/dN9J/mBHqVQ7KO
         ICEA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=K89J2IEPJbk6VmuKgUrqZ1VHo+WQOc0Cte4m7yFZoOE=;
        b=g2HkgWmRaRNqjOYfNJCC738SPBjrW2pBYvyrHq5eUmCmJexAkjX3VCBTczybIq8T9E
         1y/XwLm3sURKDbeSD4WBXBr0lG48P3mtyAGoe/vETNtSPV/V/sqtvDuEEgVHEREdjSnf
         5SsQ+PlPjsLCRYvVfTAmrtQOVydzC257uveP4VfnB/y39Gu1BtWpzvVYJP/ZLANPUda3
         JsvDyf6yod9MHW28Eg1zulg1RwkRvAsWZWTPqgDraTX7E2qM0iS9Z65WZTlUQD0+xS+D
         TWRCWSLHOWkkwTCuKrLCVTnOJ4T2cf5Udi1L+Gew57cYfd3AULudDwg4Q1lHsHyYOuYZ
         K+PA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=FxK9AQGw;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id v141si11076203ybv.172.2019.07.19.19.03.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Jul 2019 19:03:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) client-ip=216.228.121.64;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=FxK9AQGw;
       spf=pass (google.com: domain of jhubbard@nvidia.com designates 216.228.121.64 as permitted sender) smtp.mailfrom=jhubbard@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate101.nvidia.com (Not Verified[216.228.121.13]) by hqemgate15.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5d3276920000>; Fri, 19 Jul 2019 19:04:02 -0700
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate101.nvidia.com (PGP Universal service);
  Fri, 19 Jul 2019 19:03:55 -0700
X-PGP-Universal: processed;
	by hqpgpgate101.nvidia.com on Fri, 19 Jul 2019 19:03:55 -0700
Received: from [10.110.48.28] (10.124.1.5) by HQMAIL107.nvidia.com
 (172.20.187.13) with Microsoft SMTP Server (TLS) id 15.0.1473.3; Sat, 20 Jul
 2019 02:03:54 +0000
Subject: Re: [PATCH] mm/migrate: initialize pud_entry in migrate_vma()
To: Ralph Campbell <rcampbell@nvidia.com>, <linux-mm@kvack.org>
CC: <linux-kernel@vger.kernel.org>, <stable@vger.kernel.org>,
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Andrew Morton
	<akpm@linux-foundation.org>
References: <20190719233225.12243-1-rcampbell@nvidia.com>
X-Nvconfidentiality: public
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <de0f0abd-d521-9b68-80b2-92e06c6bb8ac@nvidia.com>
Date: Fri, 19 Jul 2019 19:03:54 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190719233225.12243-1-rcampbell@nvidia.com>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL105.nvidia.com (172.20.187.12) To
 HQMAIL107.nvidia.com (172.20.187.13)
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1563588242; bh=K89J2IEPJbk6VmuKgUrqZ1VHo+WQOc0Cte4m7yFZoOE=;
	h=X-PGP-Universal:Subject:To:CC:References:X-Nvconfidentiality:From:
	 Message-ID:Date:User-Agent:MIME-Version:In-Reply-To:
	 X-Originating-IP:X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=FxK9AQGwhecU2l9E5xWnRjCI47IQqIB1G9YP1qaTQccoxr6/fiLGGjY0YSYude6Ss
	 ldx4YsThY7WOYGW4UCOdZSHrOrMLWRiaOTTqh477zVcFtymsttcJvuAtY4Kshpzop0
	 05PJiu02FZmZ+NtH84hCL4TFh8r/ULQplJ+ck6f5iEkLuxOYPAGxEadkPzJhh3hB4q
	 IUYfFsqgnuCrhIfSyTwbQMWR6k03sGAIe3VaTzUem3j/u0Ougpqao7phyGoi//a8jr
	 hWzwc654tVQdZg+yMN4xCgTR00cQoYFuD3oWQHcYpWnpmuw23c/tdcZX3fkdD6w1+o
	 8ynbqObsmbohw==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 7/19/19 4:32 PM, Ralph Campbell wrote:
> When CONFIG_MIGRATE_VMA_HELPER is enabled, migrate_vma() calls
> migrate_vma_collect() which initializes a struct mm_walk but
> didn't initialize mm_walk.pud_entry. (Found by code inspection)
> Use a C structure initialization to make sure it is set to NULL.
>=20
> Fixes: 8763cb45ab967 ("mm/migrate: new memory migration helper for use wi=
th
> device memory")
> Cc: stable@vger.kernel.org
> Signed-off-by: Ralph Campbell <rcampbell@nvidia.com>
> Cc: "J=C3=A9r=C3=B4me Glisse" <jglisse@redhat.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> ---
>  mm/migrate.c | 17 +++++++----------
>  1 file changed, 7 insertions(+), 10 deletions(-)
>=20
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 515718392b24..a42858d8e00b 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -2340,16 +2340,13 @@ static int migrate_vma_collect_pmd(pmd_t *pmdp,
>  static void migrate_vma_collect(struct migrate_vma *migrate)
>  {
>  	struct mmu_notifier_range range;
> -	struct mm_walk mm_walk;
> -
> -	mm_walk.pmd_entry =3D migrate_vma_collect_pmd;
> -	mm_walk.pte_entry =3D NULL;
> -	mm_walk.pte_hole =3D migrate_vma_collect_hole;
> -	mm_walk.hugetlb_entry =3D NULL;
> -	mm_walk.test_walk =3D NULL;
> -	mm_walk.vma =3D migrate->vma;
> -	mm_walk.mm =3D migrate->vma->vm_mm;
> -	mm_walk.private =3D migrate;
> +	struct mm_walk mm_walk =3D {
> +		.pmd_entry =3D migrate_vma_collect_pmd,
> +		.pte_hole =3D migrate_vma_collect_hole,
> +		.vma =3D migrate->vma,
> +		.mm =3D migrate->vma->vm_mm,
> +		.private =3D migrate,
> +	};

Neatly done.

> =20
>  	mmu_notifier_range_init(&range, MMU_NOTIFY_CLEAR, 0, NULL, mm_walk.mm,
>  				migrate->start,
>=20

Reviewed-by: John Hubbard <jhubbard@nvidia.com>

thanks,
--=20
John Hubbard
NVIDIA

