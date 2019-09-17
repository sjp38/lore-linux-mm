Return-Path: <SRS0=uo52=XM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 37E2AC4CECE
	for <linux-mm@archiver.kernel.org>; Tue, 17 Sep 2019 17:49:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0292521670
	for <linux-mm@archiver.kernel.org>; Tue, 17 Sep 2019 17:49:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="qVC1Yn8W"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0292521670
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 95E736B0003; Tue, 17 Sep 2019 13:49:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 90DA76B0005; Tue, 17 Sep 2019 13:49:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 822C86B0006; Tue, 17 Sep 2019 13:49:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0076.hostedemail.com [216.40.44.76])
	by kanga.kvack.org (Postfix) with ESMTP id 5D3E06B0003
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 13:49:03 -0400 (EDT)
Received: from smtpin16.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id E0E9C180AD804
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 17:49:02 +0000 (UTC)
X-FDA: 75945148524.16.brass19_4eee3000eff26
X-HE-Tag: brass19_4eee3000eff26
X-Filterd-Recvd-Size: 4451
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by imf37.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 17 Sep 2019 17:49:02 +0000 (UTC)
Received: from willie-the-truck (236.31.169.217.in-addr.arpa [217.169.31.236])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id C097E2067B;
	Tue, 17 Sep 2019 17:48:56 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1568742541;
	bh=FSMaJ2t0Ern/akbZqXA6ZM9C06TUV99X2yV0MmFQdIY=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=qVC1Yn8WLaMgltxhSWwtZ1BYX0hq/DSbyp0YXdeNlM05RTalJwaz1IdVR1mxCzoJH
	 2jmDhZkbbGMRBlKa6G2ByAcodEBcn7IHRlMrnZPWSTSdXe0iGFIIYax0IibhrMPMWE
	 OIHBacY3JQfNPSG4m91Q8dCXzhQH97JIW/fn0LMc=
Date: Tue, 17 Sep 2019 18:48:53 +0100
From: Will Deacon <will@kernel.org>
To: Alexander Duyck <alexander.duyck@gmail.com>
Cc: virtio-dev@lists.oasis-open.org, kvm@vger.kernel.org, mst@redhat.com,
	catalin.marinas@arm.com, david@redhat.com, dave.hansen@intel.com,
	linux-kernel@vger.kernel.org, willy@infradead.org,
	mhocko@kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org,
	linux-arm-kernel@lists.infradead.org, osalvador@suse.de,
	yang.zhang.wz@gmail.com, pagupta@redhat.com, konrad.wilk@oracle.com,
	nitesh@redhat.com, riel@surriel.com, lcapitulino@redhat.com,
	wei.w.wang@intel.com, aarcange@redhat.com, ying.huang@intel.com,
	pbonzini@redhat.com, dan.j.williams@intel.com,
	fengguang.wu@intel.com, alexander.h.duyck@linux.intel.com,
	kirill.shutemov@linux.intel.com
Subject: Re: [PATCH v9 5/8] arm64: Move hugetlb related definitions out of
 pgtable.h to page-defs.h
Message-ID: <20190917174853.5csycb5pb5zalsxd@willie-the-truck>
References: <20190907172225.10910.34302.stgit@localhost.localdomain>
 <20190907172545.10910.88045.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190907172545.10910.88045.stgit@localhost.localdomain>
User-Agent: NeoMutt/20170113 (1.7.2)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, Sep 07, 2019 at 10:25:45AM -0700, Alexander Duyck wrote:
> From: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> 
> Move the static definition for things such as HUGETLB_PAGE_ORDER out of
> asm/pgtable.h and place it in page-defs.h. By doing this the includes
> become much easier to deal with as currently arm64 is the only architecture
> that didn't include this definition in the asm/page.h file or a file
> included by it.
> 
> It also makes logical sense as PAGE_SHIFT was already defined in
> page-defs.h so now we also have HPAGE_SHIFT defined there as well.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> ---
>  arch/arm64/include/asm/page-def.h |    9 +++++++++
>  arch/arm64/include/asm/pgtable.h  |    9 ---------
>  2 files changed, 9 insertions(+), 9 deletions(-)
> 
> diff --git a/arch/arm64/include/asm/page-def.h b/arch/arm64/include/asm/page-def.h
> index f99d48ecbeef..1c5b079e2482 100644
> --- a/arch/arm64/include/asm/page-def.h
> +++ b/arch/arm64/include/asm/page-def.h
> @@ -20,4 +20,13 @@
>  #define CONT_SIZE		(_AC(1, UL) << (CONT_SHIFT + PAGE_SHIFT))
>  #define CONT_MASK		(~(CONT_SIZE-1))
>  
> +/*
> + * Hugetlb definitions.
> + */
> +#define HUGE_MAX_HSTATE		4
> +#define HPAGE_SHIFT		PMD_SHIFT
> +#define HPAGE_SIZE		(_AC(1, UL) << HPAGE_SHIFT)
> +#define HPAGE_MASK		(~(HPAGE_SIZE - 1))
> +#define HUGETLB_PAGE_ORDER	(HPAGE_SHIFT - PAGE_SHIFT)
> +
>  #endif /* __ASM_PAGE_DEF_H */
> diff --git a/arch/arm64/include/asm/pgtable.h b/arch/arm64/include/asm/pgtable.h
> index 7576df00eb50..06a376de9bd6 100644
> --- a/arch/arm64/include/asm/pgtable.h
> +++ b/arch/arm64/include/asm/pgtable.h
> @@ -305,15 +305,6 @@ static inline int pte_same(pte_t pte_a, pte_t pte_b)
>   */
>  #define pte_mkhuge(pte)		(__pte(pte_val(pte) & ~PTE_TABLE_BIT))
>  
> -/*
> - * Hugetlb definitions.
> - */
> -#define HUGE_MAX_HSTATE		4
> -#define HPAGE_SHIFT		PMD_SHIFT
> -#define HPAGE_SIZE		(_AC(1, UL) << HPAGE_SHIFT)
> -#define HPAGE_MASK		(~(HPAGE_SIZE - 1))
> -#define HUGETLB_PAGE_ORDER	(HPAGE_SHIFT - PAGE_SHIFT)
> -

Acked-by: Will Deacon <will@kernel.org>

I'm assuming you're taking this along with the other patches, but please
shout if you'd rather it went via the arm64 tree.

Will

