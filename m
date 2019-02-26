Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 93810C43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 15:12:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3DE622173C
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 15:12:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3DE622173C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B1C058E0003; Tue, 26 Feb 2019 10:12:42 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ACA108E0001; Tue, 26 Feb 2019 10:12:42 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9E1D98E0003; Tue, 26 Feb 2019 10:12:42 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 457488E0001
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 10:12:42 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id k32so5468447edc.23
        for <linux-mm@kvack.org>; Tue, 26 Feb 2019 07:12:42 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=9BPqM8eYhBa5lrAQeQJdIOPlJr26oPl1Gz+l8DsC1L0=;
        b=EIPmSJXH5tjlg+dNa5mxOXZ+CURnHxfGrHMtyG06rwhkqKSRgvriSfEgPzaOM9TFWK
         3vBxwAdBqeFs2xZVub+DqB2gNWapiX6oDHPEssxhhofXepjWntmFnKnjKDozHKvAa3Z6
         mr6OVZgkXmQ7fHKawtmr0j3OJeOKXT9H8pLhaUahPz32xMpIUkuHmCMI+bH+YSTvI1x9
         reRldq+vcF4NFGgCC2AsJq99vimDoD0kV7pKPAMDq25gRcKkJ824Sl769EHYs1/4pRc3
         ivLenwYOXB8nTC2eWB+5su8TTia/VciQFrXntyzUTxDsVTlBWBWRPhZM/leiTqdSGoE4
         0z8g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
X-Gm-Message-State: AHQUAubBgw7GVn1EMuQMaXb5cOI2U0FaMnIZh9ZCai99Ey8sqeX9RorA
	FzfuSagY/Xl1qrWv7v1TaykkP5KRzCK9v2M1I32eB9ZLsBgf87zp6ZOIcd8w6ODsWkFxGXtHqgj
	lyolB1WuEZ3DJeS+ZNLbsGxzSa8z/DsX7G9ThqTPHsLCsDlwf/A/x2KKGR/w3jZXIaA==
X-Received: by 2002:a17:906:344f:: with SMTP id d15mr17095988ejb.40.1551193961792;
        Tue, 26 Feb 2019 07:12:41 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYcfA8TI6oPBWBleUKU54X/Dz5YVxBiN2jIeY5GHyiYJv6AtAtFOytRWwxF+ruEoMuD/pgV
X-Received: by 2002:a17:906:344f:: with SMTP id d15mr17095918ejb.40.1551193960637;
        Tue, 26 Feb 2019 07:12:40 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551193960; cv=none;
        d=google.com; s=arc-20160816;
        b=UXSiLp3DYCchazl/9fMfyy0LpMZXbAtjEJgH3Yumovh4/RUaB8VHkJ8+teHCmjKo3j
         4vgs5jjevbNb4B/YsEkjUjAZpIegB8yF6FoNJvasFREjwUGpmXtJL/ePsefyAIjg9h7v
         d797Fq6qUHzx3fKS49N6NUpRcLFGEFvqUs0wqm8fG5a5qTLMDwUD/mBtHdmk26QydCZa
         W3ktOj0P41S075sSzTUHxClH0ta8AQQ8lb1et2TCvAHl51t2ij89HQoI7E78TJyjk/Ds
         KxoJWPxb9rBZGiWFYtHgPqWLwoidKXwC32Hb4T/pGLWOuJ882ytiBhwD99szlQSqXv9y
         /JsQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=9BPqM8eYhBa5lrAQeQJdIOPlJr26oPl1Gz+l8DsC1L0=;
        b=jroS8zL3gl3m0DHq9I3RBFUkzlm1jha35D/aVXuGnDzqh5SiwKpciZAjmbH+OnNFTG
         5K/IMrEO1FRuviLr+MASqVeyRTCL7QKT2Ub3/b+Tn+RNF8vF33KKzC5NQu/Mcwx4R0Sx
         baeAgUtR+NDCFa5wsEmggouZ6tLkqQlpPQtUqbUaJm4SdDYUlnGNr74SCsbut1CmMwCN
         NUeYwV6X/g53EofjoGl0yPaNWMESXI8MPVhh2xyLYSXkw6Fl1QXxCZsvqbTz8HB5SJBT
         7HGjh6l2E877kyo6bsTrtNwAxgLktBKdHEKv9vYXU6apecX8GHIvhBeG0uNFa3yMSNVt
         kQZA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id l32si2679352edc.229.2019.02.26.07.12.40
        for <linux-mm@kvack.org>;
        Tue, 26 Feb 2019 07:12:40 -0800 (PST)
Received-SPF: pass (google.com: domain of mark.rutland@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mark.rutland@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=mark.rutland@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 953BBA78;
	Tue, 26 Feb 2019 07:12:39 -0800 (PST)
Received: from lakrids.cambridge.arm.com (usa-sjc-imap-foss1.foss.arm.com [10.72.51.249])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id C32803F575;
	Tue, 26 Feb 2019 07:12:36 -0800 (PST)
Date: Tue, 26 Feb 2019 15:12:31 +0000
From: Mark Rutland <mark.rutland@arm.com>
To: Yu Zhao <yuzhao@google.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	"Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Nick Piggin <npiggin@gmail.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Joel Fernandes <joel@joelfernandes.org>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Chintan Pandya <cpandya@codeaurora.org>,
	Jun Yao <yaojun8558363@gmail.com>,
	Laura Abbott <labbott@redhat.com>,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	linux-arch@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH v2 1/3] arm64: mm: use appropriate ctors for page tables
Message-ID: <20190226151230.GA20230@lakrids.cambridge.arm.com>
References: <20190214211642.2200-1-yuzhao@google.com>
 <20190218231319.178224-1-yuzhao@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190218231319.178224-1-yuzhao@google.com>
User-Agent: Mutt/1.11.1+11 (2f07cb52) (2018-12-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, Feb 18, 2019 at 04:13:17PM -0700, Yu Zhao wrote:
> For pte page, use pgtable_page_ctor(); for pmd page, use
> pgtable_pmd_page_ctor() if not folded; and for the rest (pud,
> p4d and pgd), don't use any.
> 
> Signed-off-by: Yu Zhao <yuzhao@google.com>
> ---
>  arch/arm64/mm/mmu.c | 33 +++++++++++++++++++++------------
>  1 file changed, 21 insertions(+), 12 deletions(-)

[...]

> -static phys_addr_t pgd_pgtable_alloc(void)
> +static phys_addr_t pgd_pgtable_alloc(int shift)
>  {
>  	void *ptr = (void *)__get_free_page(PGALLOC_GFP);
> -	if (!ptr || !pgtable_page_ctor(virt_to_page(ptr)))
> -		BUG();
> +	BUG_ON(!ptr);
> +
> +	/*
> +	 * Initialize page table locks in case later we need to
> +	 * call core mm functions like apply_to_page_range() on
> +	 * this pre-allocated page table.
> +	 */
> +	if (shift == PAGE_SHIFT)
> +		BUG_ON(!pgtable_page_ctor(virt_to_page(ptr)));
> +	else if (shift == PMD_SHIFT && PMD_SHIFT != PUD_SHIFT)
> +		BUG_ON(!pgtable_pmd_page_ctor(virt_to_page(ptr)));

IIUC, this is for nopmd kernels, where we only have real PGD and PTE
levels of table. From my PoV, that would be clearer if we did:

	else if (shift == PMD_SHIFT && !is_defined(__PAGETABLE_PMD_FOLDED))

... though IMO it would be a bit nicer if the generic
pgtable_pmd_page_ctor() were nop'd out for __PAGETABLE_PMD_FOLDED
builds, so that callers don't have to be aware of folding.

I couldn't think of a nicer way of distinguishing levels of table, and
having separate function pointers for each level seems over-the-top, so
otehr than that this looks good to me.

Assuming you're happy with the above change:

Acked-by: Mark Rutland <mark.rutland@arm.com>

Thanks,
Mark.

