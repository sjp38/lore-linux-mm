Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0DBDBC0650F
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 05:42:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C4F312089E
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 05:42:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C4F312089E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ellerman.id.au
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5D5D66B0007; Thu,  8 Aug 2019 01:42:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 587006B0008; Thu,  8 Aug 2019 01:42:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 44E2E6B000A; Thu,  8 Aug 2019 01:42:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 11EC86B0007
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 01:42:44 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id a5so54867354pla.3
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 22:42:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:in-reply-to:references:date:message-id:mime-version;
        bh=x5gANm5t0wVSKMk+V5nHqsMbOwxFEj90jE/1ngmtkFg=;
        b=AqG9Xu+IUIPEiyLUSLOKgVx+/Zwt+qapUeNbA86O6h4RPjw0oPT4Rr3NnhAFBatoUv
         wkAMXFZ7ZCMRJcpCn0ccFyAGVFY8Xyx+blJQbmIxAF31zwF0xhugUsss6KtkKu0UF50J
         qlQF842/nyd+r6JJPbcl05n0D0aesrysx0zk3h5axC0BkrnSO17SloEC0zTH52Ho3SR1
         W/zdY91a6dOtoG+bGWQGmwAuYz5thi5bwJOjyJZhYdYmaS/zH89EmbGjfN3Y0ddMUNjo
         8Cb6mYMUIcsRRic5Qregnk3X7TCRLHc2C3/24TX3JYJv9r5ao4Z/2TvbHUVkNE5T6dru
         4ViQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mpe@ellerman.id.au designates 2401:3900:2:1::2 as permitted sender) smtp.mailfrom=mpe@ellerman.id.au
X-Gm-Message-State: APjAAAWoy8l5cOH/g7KDWOyUExKzBjpSkdXMZdX37phz7iakkcMN0ypf
	bL4CD9mFS8b/s12uPFGuuCwNMPqNNqh+/mkSL2NWGx500IbtPsf9Vzp/RB9uBxWcfpZ9VuD4QOw
	FtOONob/iHQmS/nW/X5iPoOFTvfT0weobdbfveB56LXvIXAQrv1VEnVPm9A5nNC+ZtA==
X-Received: by 2002:a17:90a:3401:: with SMTP id o1mr2166329pjb.7.1565242963622;
        Wed, 07 Aug 2019 22:42:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzZg0aldOwsdgx3RguBNKZDA6pqqoNwTtyyn0SznUEVoPWVn+KwuAuvNjQvVj+k3PIgLF0u
X-Received: by 2002:a17:90a:3401:: with SMTP id o1mr2166280pjb.7.1565242962841;
        Wed, 07 Aug 2019 22:42:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565242962; cv=none;
        d=google.com; s=arc-20160816;
        b=EgriUkXMy4fwKeQPwTvq5oU70xAX9JQ+KIeUDkTH5Wvp01XDPpV5zR6Ebczp87kjCM
         kXFCreXbxkn0ZkTuyod/Q1NzvRoyM7yMLzLAA0y8rttuGpEUki5g9k97vd8aehS/Glhv
         +SnKXNS/kqYhTtfd/ivDx3fNcbzBde/GBy408sBsd47QMDhLBwEnUdmLf8AwMU77RgCY
         N9DuK10LzNMqgSiSPovknOka+Kez3clYzoYLeWv18M5vGjPXy/k9RIstNorJj+quF07O
         3kK+XGy+QJ7Jyex7riKprQn8DglxvSRATNfu07RPQqBvvbSrZCBF7DU3RP5aqKX7VYx1
         99rw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:references:in-reply-to:subject:cc:to
         :from;
        bh=x5gANm5t0wVSKMk+V5nHqsMbOwxFEj90jE/1ngmtkFg=;
        b=h2OZ4Lq1wkn0y/YzpeplNfvzih99qB549iBu8/zyx/+yA7u6kOwHldiYQeaskxAJMQ
         Xc/aYZqG3cixlcK0RgWXqyhaprMiAnfWYLJ4KQdYhMJqkYCHAer5w9X+z7mAupWd0uxu
         qbz8/9SSW97iuSQJ0k4bgt4LBf7kraIsJ1pXHToaMj4hmIgJUx/N6ulzrbqIRTls4mXk
         d1P8UgAZn3r4FmkHp2D/u9jLcHWW+R8M6KEbnyyRncmki+a0yMNjpQa8Zr1xJgCjmZC3
         RK9Mhui2J2ty61xjXiy/B2RziMVaQ4Ly6pFB12yZsQy7e9YaOsBLTvkarssDg6cremA7
         KYvw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mpe@ellerman.id.au designates 2401:3900:2:1::2 as permitted sender) smtp.mailfrom=mpe@ellerman.id.au
Received: from ozlabs.org (bilbo.ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id cp10si49193017plb.301.2019.08.07.22.42.42
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Wed, 07 Aug 2019 22:42:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of mpe@ellerman.id.au designates 2401:3900:2:1::2 as permitted sender) client-ip=2401:3900:2:1::2;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mpe@ellerman.id.au designates 2401:3900:2:1::2 as permitted sender) smtp.mailfrom=mpe@ellerman.id.au
Received: from authenticated.ozlabs.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (P-256) server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by mail.ozlabs.org (Postfix) with ESMTPSA id 463y252c4Xz9sN1;
	Thu,  8 Aug 2019 15:42:37 +1000 (AEST)
From: Michael Ellerman <mpe@ellerman.id.au>
To: john.hubbard@gmail.com, Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@infradead.org>, Dan Williams
 <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Dave
 Hansen <dave.hansen@linux.intel.com>, Ira Weiny <ira.weiny@intel.com>, Jan
 Kara <jack@suse.cz>, Jason Gunthorpe <jgg@ziepe.ca>, =?utf-8?B?SsOpcsO0?=
 =?utf-8?B?bWU=?= Glisse
 <jglisse@redhat.com>, LKML <linux-kernel@vger.kernel.org>,
 amd-gfx@lists.freedesktop.org, ceph-devel@vger.kernel.org,
 devel@driverdev.osuosl.org, devel@lists.orangefs.org,
 dri-devel@lists.freedesktop.org, intel-gfx@lists.freedesktop.org,
 kvm@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
 linux-block@vger.kernel.org, linux-crypto@vger.kernel.org,
 linux-fbdev@vger.kernel.org, linux-fsdevel@vger.kernel.org,
 linux-media@vger.kernel.org, linux-mm@kvack.org,
 linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org,
 linux-rpi-kernel@lists.infradead.org, linux-xfs@vger.kernel.org,
 netdev@vger.kernel.org, rds-devel@oss.oracle.com,
 sparclinux@vger.kernel.org, x86@kernel.org,
 xen-devel@lists.xenproject.org, John Hubbard <jhubbard@nvidia.com>,
 Benjamin Herrenschmidt <benh@kernel.crashing.org>, Christoph Hellwig
 <hch@lst.de>, linuxppc-dev@lists.ozlabs.org
Subject: Re: [PATCH v3 38/41] powerpc: convert put_page() to put_user_page*()
In-Reply-To: <20190807013340.9706-39-jhubbard@nvidia.com>
References: <20190807013340.9706-1-jhubbard@nvidia.com> <20190807013340.9706-39-jhubbard@nvidia.com>
Date: Thu, 08 Aug 2019 15:42:34 +1000
Message-ID: <87k1botdpx.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi John,

john.hubbard@gmail.com writes:
> diff --git a/arch/powerpc/mm/book3s64/iommu_api.c b/arch/powerpc/mm/book3s64/iommu_api.c
> index b056cae3388b..e126193ba295 100644
> --- a/arch/powerpc/mm/book3s64/iommu_api.c
> +++ b/arch/powerpc/mm/book3s64/iommu_api.c
> @@ -203,6 +202,7 @@ static void mm_iommu_unpin(struct mm_iommu_table_group_mem_t *mem)
>  {
>  	long i;
>  	struct page *page = NULL;
> +	bool dirty = false;

I don't think you need that initialisation do you?

>  	if (!mem->hpas)
>  		return;
> @@ -215,10 +215,9 @@ static void mm_iommu_unpin(struct mm_iommu_table_group_mem_t *mem)
>  		if (!page)
>  			continue;
>  
> -		if (mem->hpas[i] & MM_IOMMU_TABLE_GROUP_PAGE_DIRTY)
> -			SetPageDirty(page);
> +		dirty = mem->hpas[i] & MM_IOMMU_TABLE_GROUP_PAGE_DIRTY;
> -		put_page(page);
> +		put_user_pages_dirty_lock(&page, 1, dirty);
>  		mem->hpas[i] = 0;
>  	}
>  }

cheers

