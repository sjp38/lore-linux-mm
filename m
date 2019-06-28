Return-Path: <SRS0=7Cer=U3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 936E1C5B579
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 10:20:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6482220645
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 10:20:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6482220645
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E45296B0003; Fri, 28 Jun 2019 06:20:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DF53E8E0003; Fri, 28 Jun 2019 06:20:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CE3658E0002; Fri, 28 Jun 2019 06:20:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7D28A6B0003
	for <linux-mm@kvack.org>; Fri, 28 Jun 2019 06:20:09 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id b21so8647684edt.18
        for <linux-mm@kvack.org>; Fri, 28 Jun 2019 03:20:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=QZ0ly4oUftyR5ySntFBwDP3USgH45/JIGMJo3GowvVQ=;
        b=cdjQHSRskSMpcE3p/frU6iL45+mLSGdQEUFTUqUZh8r5B32usA6GOd1GkU57z6ocEi
         zq8wOLaHjflTxRoPPPWLrTWtlKOt5aXQB+JvYutlou8GyeJhcq47PbNhxYZpObqiv6t4
         BS8R3QVR2WOQFiiXZU10fc3xUtky/F3MnqGAkFD6IfsZ1V2bRjfaWnFcNxIrHPEFbTS6
         byo94GHMvybXFMZEww4ZSP7UUAWDkDBsfJwr5A9FCXvjSjhmTMwS2wfhs/kDsH/ILLv5
         YGqEVqqUfGGdVr9p3/uyydVf1xF1JTLFBkBdrsrZULl6QXQBnUdCgBDTm5EqG+mJV3YR
         Hxcg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
X-Gm-Message-State: APjAAAXm07E+T4U6Xxruny8ArVX3MGNGR+DrU3nSXb3f6/P7FqTAuA9b
	I/yDZQdLvUqM69ey6o3o51Wqd0gCYs16zjfcjF3xuvTQa2qJthgr4HntRu7/zZIgEvZ7tT2JDuV
	5X4vMYobs1EpW9E6Ltubu2D/rX+zRphzj7KvNAlYx/Y6Vk/ad4E1AU/C4YFGXjXsmRQ==
X-Received: by 2002:a17:906:2f15:: with SMTP id v21mr7974251eji.113.1561717208958;
        Fri, 28 Jun 2019 03:20:08 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxtNIW1NU8CTFEVqqyxmo82diUteRR/w/CXHdEe9AuHyuidCAp81qkNciMeDpYt1dG8YzT/
X-Received: by 2002:a17:906:2f15:: with SMTP id v21mr7974177eji.113.1561717208079;
        Fri, 28 Jun 2019 03:20:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561717208; cv=none;
        d=google.com; s=arc-20160816;
        b=s9Bm1k7z6gfvPDC4cBiTrt7MIeW9qKTPcVM5/rgm+dKpfllpHtoNshH/PJmylkHik4
         rberN2t+PdaeQQMkQ07oMU3e7DQtQFtNiNQqcz6HzirtWBLpuzpRpQ/d6kadR5fXQT2B
         mu+E7KBCt+jhiBncm1UvSpAwORRM4Zu09N+PAH/B4dweDOPePh5RbgvP+YouHYOoP6m7
         PFne+BSPhBd9dfmcqxi+RMSDdkNPopIeCEAtOJGx20ofX+S5iT0Bx2Rtfx61tBLdDQvL
         2c7A0PBAQC2wJg9rZvSRIB4e4f3RbGBAMiaGB/8OmNC8GdasFJlA1glW1lRWboO7iua2
         GvGA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=QZ0ly4oUftyR5ySntFBwDP3USgH45/JIGMJo3GowvVQ=;
        b=YbcHG9TOOzpYlyqZTMZfnRzYwjdPtUg2KRbu2aZaR0UB+rQloMhcGYnEZEA5njmV/J
         +YHhm+e26b2yQT9A5kB5md4WwdKSwR3dA2qa4nuFWuUMwxyeIENNKFhj/u18fIfXeZ14
         xfG39jq5lwNUce98qPrnhRLss/LzQXyBopEAYk+TQzi63XsKy6i7N+8hJyHxqj5oUmPS
         CiKJO39EAu0OhUkPBXRC25ZePjsi8hqIe4OdCeTy/VCzewxlJ/txe7ShvqqtfUstFykv
         UQuPxpE6Byv0zgynmbje1RE9lS9Ba8zuFTngBoxlq5P++KxDuU+PkkrBJNLvAqsc9AsD
         wnEA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id w24si1157365ejv.209.2019.06.28.03.20.07
        for <linux-mm@kvack.org>;
        Fri, 28 Jun 2019 03:20:08 -0700 (PDT)
Received-SPF: pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of catalin.marinas@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=catalin.marinas@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 1ED6828;
	Fri, 28 Jun 2019 03:20:07 -0700 (PDT)
Received: from arrakis.emea.arm.com (arrakis.cambridge.arm.com [10.1.196.78])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id F05873F718;
	Fri, 28 Jun 2019 03:20:05 -0700 (PDT)
Date: Fri, 28 Jun 2019 11:20:03 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: linux-mm@kvack.org, Will Deacon <will@kernel.org>,
	Mark Rutland <mark.rutland@arm.com>,
	Marc Zyngier <marc.zyngier@arm.com>,
	Suzuki Poulose <suzuki.poulose@arm.com>,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
Subject: Re: [RFC 1/2] arm64/mm: Change THP helpers to comply with generic MM
 semantics
Message-ID: <20190628102003.GA56463@arrakis.emea.arm.com>
References: <1561639696-16361-1-git-send-email-anshuman.khandual@arm.com>
 <1561639696-16361-2-git-send-email-anshuman.khandual@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1561639696-16361-2-git-send-email-anshuman.khandual@arm.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Anshuman,

On Thu, Jun 27, 2019 at 06:18:15PM +0530, Anshuman Khandual wrote:
> pmd_present() and pmd_trans_huge() are expected to behave in the following
> manner during various phases of a given PMD. It is derived from a previous
> detailed discussion on this topic [1] and present THP documentation [2].
> 
> pmd_present(pmd):
> 
> - Returns true if pmd refers to system RAM with a valid pmd_page(pmd)
> - Returns false if pmd does not refer to system RAM - Invalid pmd_page(pmd)
> 
> pmd_trans_huge(pmd):
> 
> - Returns true if pmd refers to system RAM and is a trans huge mapping
> 
> -------------------------------------------------------------------------
> |	PMD states	|	pmd_present	|	pmd_trans_huge	|
> -------------------------------------------------------------------------
> |	Mapped		|	Yes		|	Yes		|
> -------------------------------------------------------------------------
> |	Splitting	|	Yes		|	Yes		|
> -------------------------------------------------------------------------
> |	Migration/Swap	|	No		|	No		|
> -------------------------------------------------------------------------

Before we actually start fixing this, I would strongly suggest that you
add a boot selftest (see lib/Kconfig.debug for other similar cases)
which checks the consistency of the page table macros w.r.t. the
expected mm semantics. Once the mm maintainers agreed with the
semantics, it will really help architecture maintainers in implementing
them correctly.

You wouldn't need actual page tables, just things like assertions on
pmd_trans_huge(pmd_mkhuge(pmd)) == true. You could go further and have
checks on pmdp_invalidate(&dummy_vma, dummy_addr, &dummy_pmd) with the
dummy_* variables on the stack.

> The problem:
> 
> PMD is first invalidated with pmdp_invalidate() before it's splitting. This
> invalidation clears PMD_SECT_VALID as below.
> 
> PMD Split -> pmdp_invalidate() -> pmd_mknotpresent -> Clears PMD_SECT_VALID
> 
> Once PMD_SECT_VALID gets cleared, it results in pmd_present() return false
> on the PMD entry.

I think that's an inconsistency in the expected semantics here. Do you
mean that pmd_present(pmd_mknotpresent(pmd)) should be true? If not, do
we need to implement our own pmdp_invalidate() or change the generic one
to set a "special" bit instead of just a pmd_mknotpresent?

> +static inline int pmd_present(pmd_t pmd)
> +{
> +	if (pte_present(pmd_pte(pmd)))
> +		return 1;
> +
> +	return pte_special(pmd_pte(pmd));
> +}
[...]
> +static inline pmd_t pmd_mknotpresent(pmd_t pmd)
> +{
> +	pmd = pte_pmd(pte_mkspecial(pmd_pte(pmd)));
> +	return __pmd(pmd_val(pmd) & ~PMD_SECT_VALID);
> +}

I'm not sure I agree with the semantics here where pmd_mknotpresent()
does not actually make pmd_present() == false.

-- 
Catalin

