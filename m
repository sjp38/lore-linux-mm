Return-Path: <SRS0=zC3H=RW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7031CC43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 21:51:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F0790217F4
	for <linux-mm@archiver.kernel.org>; Tue, 19 Mar 2019 21:51:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=canb.auug.org.au header.i=@canb.auug.org.au header.b="ZzVpye8l"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F0790217F4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=canb.auug.org.au
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5F1276B0005; Tue, 19 Mar 2019 17:51:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5A0806B0006; Tue, 19 Mar 2019 17:51:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 490006B0007; Tue, 19 Mar 2019 17:51:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 05D1B6B0005
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 17:51:23 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id f10so435438pgp.13
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 14:51:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version;
        bh=uxnDjXdomgMFdsdMsJ67rSXlGNIKQPisujsky9Xo44w=;
        b=mEVj04LKKcwIz/K6Xhux2AOqpb6d85Rqy9ZgJonGNa4V3+0ALqnUjQCAuLrtMycJef
         vBFTvfLxQWf9Z6IRd/D7xkGoIuqxEzCXGP/MeA36aQH4WAyZNBx8C3ODTpxbFCpd76Uh
         vCWq72IMNYIO8uBo4m1YhtV3cUFg2XhXDYU4TmDyjWwMHctebD139mQr7whd4cQ0+W39
         ZU2m0P3MXpw/KWbi24t7kOrvsXSI5Cc+Y0kTLo/v8+sIiI+Ves97XQh94nlxQlU0iay0
         HyZVpOrK0tMYF/UromN2lgXlTkc/QxphhxV2Yr8y7DoBkjBKD7peJnFe8iDkMdnmuJ1l
         02aA==
X-Gm-Message-State: APjAAAWR+Z5/9cDg4rq3xHCju4PMYrvKYBpSDpzqVTbj5/u7EaJYY1IS
	lNDtNFx9I0gy/jpv47+gHi4HMKHVxQ6X0nTft0aXALrmzyr/u6ZqCCvgM93DeFOYRJnz3+p3N7o
	pP5LEI2P9DwDxBaOwum/qBzQ11WjZv4OuIey1303rDh0yA4oohSkljN4gRJ+2Vkl97g==
X-Received: by 2002:a62:574d:: with SMTP id l74mr4213141pfb.9.1553032282643;
        Tue, 19 Mar 2019 14:51:22 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwR93ICcEiWOn1Y/jRhjKELVcuhU7g1Ibz95a+zDJh3SRLqS1L+yNztYQIyJqCgT4LvqrUx
X-Received: by 2002:a62:574d:: with SMTP id l74mr4213062pfb.9.1553032281437;
        Tue, 19 Mar 2019 14:51:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553032281; cv=none;
        d=google.com; s=arc-20160816;
        b=xZbVUH4Z8sbbDFpUHlkAjtCID4XIM1WyyF79aOhmDrDY6nq/i7lx5i363i4lUj0jXk
         6jU+lMgdumZ2ngLEjDuKmmikXSmkHVkpfCvkq6zYxWahCex2QsxDLTgaKjWiRVi48dem
         1ouLTGijVUkql9SaDH5BmbXt2ZesXU6boenWJu+smo+e1dsUIRmWsr+iU26DWc5cjUSL
         634Y/YzF+Ncm8pXyD2G0mv1jwyfS/pnEydJQgRrE/Ca3kAjK3+vzn/9AElZzrrN2ykjK
         PQ6qJU0YivuLpntMn5wzYFUyrBYLuymJOAHrmItME0qk4dEJngpjlclR2iYU4mB/m/gB
         agKA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:subject:cc:to:from
         :date:dkim-signature;
        bh=uxnDjXdomgMFdsdMsJ67rSXlGNIKQPisujsky9Xo44w=;
        b=fjXbRB/Dyp6Kx6jiysxnX1wxBdeExmtEBHh88xVJ6v8kMXgXHPS4X1csEUNT+dcI9Z
         s8/qXhOH4qUAIhpe+pbiWRA/BxNTHWCqbn5nwNrrBllHSrw5PBgiVDES/aJUKOgyH+sG
         z/NaOIUE/1smGBObB8PcIjZV7m0pIgDZcZzMh2V9475d08J4s2cETyWg+7RvnrA9W6M1
         l2FnNgh0y+ZcW64iu2gPWdrz6n50Wwjd5ON3utcBGCXC42/zVBnMzda6xSxACTeP1WQk
         NZ8ZM9VZRwmktZRmsFnjGUJQoXtWpb2S9vuXk5KGuH5aXFewAcsdb5g5BLdR5tDHPfFD
         A3xA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@canb.auug.org.au header.s=201702 header.b=ZzVpye8l;
       spf=pass (google.com: domain of sfr@canb.auug.org.au designates 2401:3900:2:1::2 as permitted sender) smtp.mailfrom=sfr@canb.auug.org.au
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id z70si42992pfl.3.2019.03.19.14.51.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 19 Mar 2019 14:51:21 -0700 (PDT)
Received-SPF: pass (google.com: domain of sfr@canb.auug.org.au designates 2401:3900:2:1::2 as permitted sender) client-ip=2401:3900:2:1::2;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@canb.auug.org.au header.s=201702 header.b=ZzVpye8l;
       spf=pass (google.com: domain of sfr@canb.auug.org.au designates 2401:3900:2:1::2 as permitted sender) smtp.mailfrom=sfr@canb.auug.org.au
Received: from authenticated.ozlabs.org (localhost [127.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (P-256) server-signature RSA-PSS (4096 bits) server-digest SHA256)
	(No client certificate requested)
	by mail.ozlabs.org (Postfix) with ESMTPSA id 44P6FJ5cLPz9sBp;
	Wed, 20 Mar 2019 08:51:16 +1100 (AEDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=canb.auug.org.au;
	s=201702; t=1553032278;
	bh=xFWnKOibxlW+QQixST4hmzvrqFXNoeUMXKcr4lOOcVM=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=ZzVpye8lF1x9wP6p0afCXWiwXfUalNydgLA/SR2STICVbq63MbNL9xjmROE7NuJ63
	 nO4vDRH2p5CeuZ631eKDq4/z8stz66JZ4EAl091WDhErkrLAQX8MV5SfuGOQTBnIXz
	 L7rTUH+BL2KVMgqtfUWrkwpkFqIhkBrW1CKtvc/LwNM8R75/l8sqviQitIEW856fHw
	 Fp+ZhseTyvOCnzw4cCkZfpz/HUN9DPf/X4SiV3oBXGk0r3K5L5lAps5ZglaSyxWj/h
	 cWlkd5laaQF0v8+tm4+RrFZEee0niw4I9PV6i05rbuyICvPHGaXbX+bHeuRsCTlfCq
	 qGoipDgBw3GMQ==
Date: Wed, 20 Mar 2019 08:51:14 +1100
From: Stephen Rothwell <sfr@canb.auug.org.au>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jerome Glisse <jglisse@redhat.com>, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org, Felix Kuehling <Felix.Kuehling@amd.com>,
 Christian =?UTF-8?B?S8O2bmln?= <christian.koenig@amd.com>, Ralph Campbell
 <rcampbell@nvidia.com>, John Hubbard <jhubbard@nvidia.com>, Jason Gunthorpe
 <jgg@mellanox.com>, Dan Williams <dan.j.williams@intel.com>, Alex Deucher
 <alexander.deucher@amd.com>
Subject: Re: [PATCH 00/10] HMM updates for 5.1
Message-ID: <20190320085114.3c60ccce@canb.auug.org.au>
In-Reply-To: <20190319101249.d2076f4bacbef948055ae758@linux-foundation.org>
References: <20190129165428.3931-1-jglisse@redhat.com>
	<20190313012706.GB3402@redhat.com>
	<20190313091004.b748502871ba0aa839b924e9@linux-foundation.org>
	<20190318170404.GA6786@redhat.com>
	<20190319094007.a47ce9222b5faacec3e96da4@linux-foundation.org>
	<20190319165802.GA3656@redhat.com>
	<20190319101249.d2076f4bacbef948055ae758@linux-foundation.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 boundary="Sig_/rZ_YS7Q3KOb_0EEI.p64CGi"; protocol="application/pgp-signature"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

--Sig_/rZ_YS7Q3KOb_0EEI.p64CGi
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

Hi Andrew,

On Tue, 19 Mar 2019 10:12:49 -0700 Andrew Morton <akpm@linux-foundation.org=
> wrote:
>
> Yes, a resend against mainline with those various updates will be
> helpful.  Please go through the various fixes which we had as well:
>=20
> mm-hmm-use-reference-counting-for-hmm-struct.patch
> mm-hmm-do-not-erase-snapshot-when-a-range-is-invalidated.patch
> mm-hmm-improve-and-rename-hmm_vma_get_pfns-to-hmm_range_snapshot.patch
> mm-hmm-improve-and-rename-hmm_vma_fault-to-hmm_range_fault.patch
> mm-hmm-improve-driver-api-to-work-and-wait-over-a-range.patch
> mm-hmm-improve-driver-api-to-work-and-wait-over-a-range-fix.patch
> mm-hmm-improve-driver-api-to-work-and-wait-over-a-range-fix-fix.patch
> mm-hmm-add-default-fault-flags-to-avoid-the-need-to-pre-fill-pfns-arrays.=
patch
> mm-hmm-add-an-helper-function-that-fault-pages-and-map-them-to-a-device.p=
atch
> mm-hmm-support-hugetlbfs-snap-shoting-faulting-and-dma-mapping.patch
> mm-hmm-allow-to-mirror-vma-of-a-file-on-a-dax-backed-filesystem.patch
> mm-hmm-allow-to-mirror-vma-of-a-file-on-a-dax-backed-filesystem-fix.patch
> mm-hmm-allow-to-mirror-vma-of-a-file-on-a-dax-backed-filesystem-fix-2.pat=
ch
> mm-hmm-add-helpers-for-driver-to-safely-take-the-mmap_sem.patch

I have dropped all those from linux-next today (along with
mm-hmm-fix-unused-variable-warnings.patch).

--=20
Cheers,
Stephen Rothwell

--Sig_/rZ_YS7Q3KOb_0EEI.p64CGi
Content-Type: application/pgp-signature
Content-Description: OpenPGP digital signature

-----BEGIN PGP SIGNATURE-----

iQEzBAEBCAAdFiEENIC96giZ81tWdLgKAVBC80lX0GwFAlyRZFIACgkQAVBC80lX
0Gw81AgAnXTKZqmeBZ4XjAsL8P7H6EEBR0UIaAyWsozfkZPGrrTgSMamze/8WwWu
JaraU0UrKqcUviCT1rKDjxiNThMMbiWqdR6q4GlndWsBUjWTp9Kdis1qBzKG84pb
j0p+0oPChjQTUkDnJ+sDu4kNzKzsI/dnELnv0eD7CBD6/7fMs0cZqPcIWOx8gU6C
ZjFRZ3rL1x62j+XQV6Soi75OUmmK3B09pcGSoveJcnczUYbWObuabzxhwIss0+Hs
uAAVyn8QqeCewozDT1RM8zJMgCsfoxVgUjjeG2OdHGH+812z2yOVXHH5FS68RqWW
rLwHse5BU5x5GObt1LUXGHPMDksB5w==
=Kvth
-----END PGP SIGNATURE-----

--Sig_/rZ_YS7Q3KOb_0EEI.p64CGi--

