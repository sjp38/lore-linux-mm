Return-Path: <SRS0=SgWF=Q5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 864D7C4360F
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 23:31:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 18F912070D
	for <linux-mm@archiver.kernel.org>; Fri, 22 Feb 2019 23:31:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=nvidia.com header.i=@nvidia.com header.b="VdbLFIEG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 18F912070D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=nvidia.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5D2678E014A; Fri, 22 Feb 2019 18:31:21 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 580048E0148; Fri, 22 Feb 2019 18:31:21 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 446D38E014A; Fri, 22 Feb 2019 18:31:21 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1AC3C8E0148
	for <linux-mm@kvack.org>; Fri, 22 Feb 2019 18:31:21 -0500 (EST)
Received: by mail-yb1-f198.google.com with SMTP id t128so2458138ybf.11
        for <linux-mm@kvack.org>; Fri, 22 Feb 2019 15:31:21 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:to:cc:references:from:message-id:date
         :user-agent:mime-version:in-reply-to:content-language
         :content-transfer-encoding:dkim-signature;
        bh=/oVuyOXOUrFyvdi2hXsVsKEk67GOJZtcuD65mETThWg=;
        b=oieEzjcDYSML5PFvYDT5Yzy4b83QOFX/pYnqMTrNAwfr2DcABw9extKgoATWXvyG2q
         j27x8xMDbN2HmkVhZoZYhsLteE+Z/NQSi94o+hlFiqJshleFE56TpJa9Dr/3Ge+WkDVy
         bnl/uJXtGDmYaCUzGEtvSHfrpmRNWSlNSK7Zy8y22PxOv2OVlMGNOKYklZbX2CvzVxOk
         bbENQYmpT/qM7z/QhN4QVM+lcwReejZl+BCuHd7jCQRrHmEwKFoItQr0zIozf+EASZC9
         hcEDJdVO0exSkIl2Dg7r1cuLGGqfR86pXWIx4y8yJou/IN6KfQV4ZROsGWPk+SP93CLc
         kA3w==
X-Gm-Message-State: AHQUAuaouc1k+6QD2Vcq8ZQPVIduc6aXergKmIs+0wlzgI7QJD5UxiXU
	olXzy/pKlPC9XYPtG1LoyfUWJvOHrhduWxGrALsakHE7zX8wJ8rJbuTaye1Lxk2/mj6heyRwI4o
	aQe3rFfbAog3Q48KC/sTUA3DA4LRBafqSqFhk0AvWBxY8SbJx0pdkoRwE1fWhVPUx0g==
X-Received: by 2002:a81:1017:: with SMTP id 23mr5435336ywq.72.1550878280659;
        Fri, 22 Feb 2019 15:31:20 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaDniPz7tcV+0XXx/ED0bwsD7gDPkVNfXFCCG3c2k+ZzapcFw0Qj90hZXs/2OpkabZg3SuL
X-Received: by 2002:a81:1017:: with SMTP id 23mr5435295ywq.72.1550878279809;
        Fri, 22 Feb 2019 15:31:19 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550878279; cv=none;
        d=google.com; s=arc-20160816;
        b=CeCB79XZPWrl2nBlk9RCF4azomSYcJaLFA+yjIMrK3PbuLyJ9LDiwVDE/dBfVGzLpj
         0MEBBKxC3lpYShMnNB0ATTYBgSaFnVxQYvZ6FOe3+DvQRenZOUYEF376DvM9AfFOCUKk
         A/KyQ0VqHXGsKSHVflOVmqhq9mbxjYBsvFFCAzibSIOJQKFXnfj6HdoS/Vg6muRRwwCE
         t3sgMZMvKOGNUXZ+h2zCdp8WJ5IESOf+q9JQzHsrtxBI6Jus/m+mZ6NytE8o8k2/6MUb
         RsD5E+znOBcmEPs9FUNdiH5Z3CZnv5k7rB1mVmpqEn/azIXCBYs4+6UqYXV5sOqSaerN
         J2gA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=dkim-signature:content-transfer-encoding:content-language
         :in-reply-to:mime-version:user-agent:date:message-id:from:references
         :cc:to:subject;
        bh=/oVuyOXOUrFyvdi2hXsVsKEk67GOJZtcuD65mETThWg=;
        b=lmA0jMm6PmrKwEqDyKplo/fPEsloNFWwNs/xAgBGtsRJPQ+rdZyMjeKiuY6GPVka2m
         70LJJMzjSGEnxMia7KnLelBdXAOJrOFoe5IshdX5VUlkYh8xGHHEEDTGm6TvKD6hGJ80
         2VUiThnKX6JXH4DGUt2hTCrnhkHj2B9yW8O+CJeugGVCFVHT1iqBCDkxBpOaUl1QIuhf
         n2/oDseLi3MGe33iYRWPI279W/DK5WcoYH+3QDjRiKFqRXLZfqAzR8E5/rsYLwTWgS48
         we1n0x/gIU62XdkyuqS3JeVACHZBt0+2pShsrPDf4Ze70hqu4cESCcQJpRgBWn899uu6
         eCAA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=VdbLFIEG;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id j15si1814467ybp.249.2019.02.22.15.31.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Feb 2019 15:31:19 -0800 (PST)
Received-SPF: pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) client-ip=216.228.121.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@nvidia.com header.s=n1 header.b=VdbLFIEG;
       spf=pass (google.com: domain of rcampbell@nvidia.com designates 216.228.121.65 as permitted sender) smtp.mailfrom=rcampbell@nvidia.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=nvidia.com
Received: from hqpgpgate102.nvidia.com (Not Verified[216.228.121.13]) by hqemgate16.nvidia.com (using TLS: TLSv1.2, DES-CBC3-SHA)
	id <B5c70864c0001>; Fri, 22 Feb 2019 15:31:24 -0800
Received: from hqmail.nvidia.com ([172.20.161.6])
  by hqpgpgate102.nvidia.com (PGP Universal service);
  Fri, 22 Feb 2019 15:31:18 -0800
X-PGP-Universal: processed;
	by hqpgpgate102.nvidia.com on Fri, 22 Feb 2019 15:31:18 -0800
Received: from rcampbell-dev.nvidia.com (10.124.1.5) by HQMAIL101.nvidia.com
 (172.20.187.10) with Microsoft SMTP Server (TLS) id 15.0.1395.4; Fri, 22 Feb
 2019 23:31:18 +0000
Subject: Re: [PATCH 00/10] HMM updates for 5.1
To: <jglisse@redhat.com>, <linux-mm@kvack.org>
CC: <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>,
	Felix Kuehling <Felix.Kuehling@amd.com>, =?UTF-8?Q?Christian_K=c3=b6nig?=
	<christian.koenig@amd.com>, John Hubbard <jhubbard@nvidia.com>, Jason
 Gunthorpe <jgg@mellanox.com>, Dan Williams <dan.j.williams@intel.com>
References: <20190129165428.3931-1-jglisse@redhat.com>
From: Ralph Campbell <rcampbell@nvidia.com>
Message-ID: <faf031d5-0aa0-e19e-0431-d5b0d0c5308d@nvidia.com>
Date: Fri, 22 Feb 2019 15:31:18 -0800
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.3.0
MIME-Version: 1.0
In-Reply-To: <20190129165428.3931-1-jglisse@redhat.com>
X-Originating-IP: [10.124.1.5]
X-ClientProxiedBy: HQMAIL104.nvidia.com (172.18.146.11) To
 HQMAIL101.nvidia.com (172.20.187.10)
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=nvidia.com; s=n1;
	t=1550878284; bh=/oVuyOXOUrFyvdi2hXsVsKEk67GOJZtcuD65mETThWg=;
	h=X-PGP-Universal:Subject:To:CC:References:From:Message-ID:Date:
	 User-Agent:MIME-Version:In-Reply-To:X-Originating-IP:
	 X-ClientProxiedBy:Content-Type:Content-Language:
	 Content-Transfer-Encoding;
	b=VdbLFIEGxXM1y5pTAMmuejyoxMGnLk2dVyUnfywBv2Q9XDhaZ+lJAwVhTL2n2MgfJ
	 bbXeSUeJp1KaYb4Lj8eFf18hPAQ24sV/hqS+w4A6aDc3p+A8ele4J8cnycj8DemIUH
	 5WM7DlI6cIApBRsBj90OoYGv5uYE32Hd4S/GAbuZuvOvGat4RTc92niR1G5fXuBlhR
	 htpuqmpw7qvyFeYRLQ7Pzjt1Xq4kAqU9QVKTtlpBfjpp5Az/nsNkYwSccwkIWjpmDy
	 TXwfipS6l3iefjsOPqfcNyTZGRb4GsDi4TzIMwyTmKcT94NvVDkwONUqZGKxhvBxUY
	 A0/pA3ayG5+rA==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 1/29/19 8:54 AM, jglisse@redhat.com wrote:
> From: J=C3=A9r=C3=B4me Glisse <jglisse@redhat.com>
>=20
> This patchset improves the HMM driver API and add support for hugetlbfs
> and DAX mirroring. The improvement motivation was to make the ODP to HMM
> conversion easier [1]. Because we have nouveau bits schedule for 5.1 and
> to avoid any multi-tree synchronization this patchset adds few lines of
> inline function that wrap the existing HMM driver API to the improved
> API. The nouveau driver was tested before and after this patchset and it
> builds and works on both case so there is no merging issue [2]. The
> nouveau bit are queue up for 5.1 so this is why i added those inline.
>=20
> If this get merge in 5.1 the plans is to merge the HMM to ODP in 5.2 or
> 5.3 if testing shows any issues (so far no issues has been found with
> limited testing but Mellanox will be running heavier testing for longer
> time).
>=20
> To avoid spamming mm i would like to not cc mm on ODP or nouveau patches,
> however if people prefer to see those on mm mailing list then i can keep
> it cced.
>=20
> This is also what i intend to use as a base for AMD and Intel patches
> (v2 with more thing of some rfc which were already posted in the past).
>=20
> [1] https://cgit.freedesktop.org/~glisse/linux/log/?h=3Dodp-hmm
> [2] https://cgit.freedesktop.org/~glisse/linux/log/?h=3Dhmm-for-5.1
>=20
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Felix Kuehling <Felix.Kuehling@amd.com>
> Cc: Christian K=C3=B6nig <christian.koenig@amd.com>
> Cc: Ralph Campbell <rcampbell@nvidia.com>
> Cc: John Hubbard <jhubbard@nvidia.com>
> Cc: Jason Gunthorpe <jgg@mellanox.com>
> Cc: Dan Williams <dan.j.williams@intel.com>
>=20
> J=C3=A9r=C3=B4me Glisse (10):
>    mm/hmm: use reference counting for HMM struct
>    mm/hmm: do not erase snapshot when a range is invalidated
>    mm/hmm: improve and rename hmm_vma_get_pfns() to hmm_range_snapshot()
>    mm/hmm: improve and rename hmm_vma_fault() to hmm_range_fault()
>    mm/hmm: improve driver API to work and wait over a range
>    mm/hmm: add default fault flags to avoid the need to pre-fill pfns
>      arrays.
>    mm/hmm: add an helper function that fault pages and map them to a
>      device
>    mm/hmm: support hugetlbfs (snap shoting, faulting and DMA mapping)
>    mm/hmm: allow to mirror vma of a file on a DAX backed filesystem
>    mm/hmm: add helpers for driver to safely take the mmap_sem
>=20
>   include/linux/hmm.h |  290 ++++++++++--
>   mm/hmm.c            | 1060 +++++++++++++++++++++++++++++--------------
>   2 files changed, 983 insertions(+), 367 deletions(-)
>=20

I have been testing this patch series in addition to [1] with some
success. I wouldn't go as far as saying it is thoroughly tested
but you can add:

Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>


[1] https://marc.info/?l=3Dlinux-mm&m=3D155060669514459&w=3D2
     ("[PATCH v5 0/9] mmu notifier provide context informations")

