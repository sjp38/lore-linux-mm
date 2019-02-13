Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3B3EBC282C2
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 13:17:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E440B222B1
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 13:17:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="ROpBr8h6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E440B222B1
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 723218E0002; Wed, 13 Feb 2019 08:17:16 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6D20C8E0001; Wed, 13 Feb 2019 08:17:16 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5E8E08E0002; Wed, 13 Feb 2019 08:17:16 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1D3018E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 08:17:16 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id i5so354288pfi.1
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 05:17:16 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=g258Euwx0GrLQtKmSvWxw0CICp9PokNV4/Yv5ookS90=;
        b=DDAsjStzMSSDEhd86TY0FA8XNdcz7emW6rDkoLYtanNWp5g0eDzIz6yNdo+1FI0YAN
         CsQD0g5iE0kEAp2bzLyLJ5b8eC2u9RBsBGhb2iKr2OB7rzl8wVacwm7h11ez3vaj2kqc
         saWPNg1bxFJftx/G/LyhUbMmr8vR++y+OIznY/+gv3TmpeKBJPQ+K1W0SuLSnEE9IjeA
         c3D3bV741D9eWMZE1l9JGSRXoWsFQkW29U7kNvG/nBZ2KkDSLsXLcfG+cNGBsqOnI50a
         5KKFS4J3o6pClNdVAxJHfn8KHCUCxZqt1083/rgrhdxsJ8Lc3CKG3+D1+j5r15wVK1Q+
         67Kg==
X-Gm-Message-State: AHQUAuaVUKVSq0oO/slrxashk4Q19LHxBMLkdIAuVa0a+drQdmwK1p3n
	yRZVPiaEAI56WfPJHt6OfYOtLieP6v04wifdoyhIe3QFnAimKz91dqpK4jc7+R5p2TFJJMKfVOR
	ECWhDr1m/stzRoYNs8xBNYrFTNk4BnWZK+dHc/MdkSQjXFP8D07sDKznDngiU9jHoug==
X-Received: by 2002:a62:5287:: with SMTP id g129mr520726pfb.22.1550063835779;
        Wed, 13 Feb 2019 05:17:15 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ia0gGMwXZ0RNNnHgvvEeUDO5xSiSaGBzz1Z2F2Fil3murObk8mAxuOH0KYWPaSHc+MPfLJr
X-Received: by 2002:a62:5287:: with SMTP id g129mr520661pfb.22.1550063835047;
        Wed, 13 Feb 2019 05:17:15 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550063835; cv=none;
        d=google.com; s=arc-20160816;
        b=C9aS2CLy+TcKtzY0ey5M9qOMHXoMsR/UQ1CMQnlMfRfRHKIwbb1EXXZy7aYz51kNtR
         GnRJU3YCzlUzsFYlZdBCAu4qJs2+ZWEUO2XVSydDclgzZ+QDjumWxbXPTM1HVZ2JmD77
         kU6CxXr+u3cs34jj6oMmFYwcOdc8m2ytb6908obZUtxrYRg4+K7WD6l/VwPR4lb/17iS
         B+Wmi9eFx/0EmPRBGk8VBziDHtT1GkSunFod3fHvn1c88XyKclDiNwHSNgD7E3mbw3mg
         Q4qKudtjcKvoYbf4PPGhe6ofIlyhopYifXKYnx++43yg1xXrQKsp1C1SxcAcf6KDNe7T
         CcrA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=g258Euwx0GrLQtKmSvWxw0CICp9PokNV4/Yv5ookS90=;
        b=NMZkKGMAjQVPQIDNdSf29Z618V78moTC2byJOJK2jtO/VMHa/H2+61U/Dczzw86Gdd
         Yc2mGvrcRcQbc6jJ1S4UUj0gPQuj3/Xi7vJK3fZKIovpjKdHGjjgjCfDjg1qV0nTsg5u
         9+OqbTqqkIze8THSCHb0yw/j2xqr1CE1KP3jvDgLeKkhohKVlWZrXMh8R4qnm3G4VzmN
         7xLIGaSfYfdSx07BUdchnByiqlrkIiGlx9kmEgoy5+GhLNABF8NrFtsIaSYLLhYhgmEo
         wMhcSf7hptQVHvot2JM/2oTxshhQ9jvgq//i0XtjrbJi6tXHCFg3k8WmCC1obOgrfGfi
         urCw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=ROpBr8h6;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id i72si5551863pfi.52.2019.02.13.05.17.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 13 Feb 2019 05:17:15 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=ROpBr8h6;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=g258Euwx0GrLQtKmSvWxw0CICp9PokNV4/Yv5ookS90=; b=ROpBr8h67o5e75H2FUd/lLVfM
	u6I13qq/lEPQLC2MlT5i7JauXenxPe8ri8dIBdqxo/DGvTMJLYoVCzFUqN+H2Vt9eSmbo4znPaoSl
	q/RSbrkG6zw5Wj1RJ39V9tPtvnKjFE1mSUrxzLsFSkhZxpDZWUZlGEPGtuhwcSUSzhigALi7YVRQF
	CNRHjkBeMsihplz7JRmDydJHk5jdbbUwDVZkQd0QPEkw1AJrmfoasfW/B6gFiOlHcfF0G7V0qxplb
	LTBkavhsR7gSPSjcqi2L255rWsd/oOrc4nSDmJz2HuuI7uUuXX0WyJ+/VKQQKpHZ9dkOo9LA8YoEO
	1ZjGMhjjw==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gtuPW-0005n1-LV; Wed, 13 Feb 2019 13:17:10 +0000
Date: Wed, 13 Feb 2019 05:17:10 -0800
From: Matthew Wilcox <willy@infradead.org>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, mhocko@kernel.org,
	kirill@shutemov.name, kirill.shutemov@linux.intel.com,
	vbabka@suse.cz, will.deacon@arm.com, catalin.marinas@arm.com,
	dave.hansen@intel.com
Subject: Re: [RFC 1/4] mm: Introduce lazy exec permission setting on a page
Message-ID: <20190213131710.GR12668@bombadil.infradead.org>
References: <1550045191-27483-1-git-send-email-anshuman.khandual@arm.com>
 <1550045191-27483-2-git-send-email-anshuman.khandual@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1550045191-27483-2-git-send-email-anshuman.khandual@arm.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 13, 2019 at 01:36:28PM +0530, Anshuman Khandual wrote:
> +#ifdef CONFIG_ARCH_SUPPORTS_LAZY_EXEC
> +static inline pte_t maybe_mkexec(pte_t entry, struct vm_area_struct *vma)
> +{
> +	if (unlikely(vma->vm_flags & VM_EXEC))
> +		return pte_mkexec(entry);
> +	return entry;
> +}
> +#else
> +static inline pte_t maybe_mkexec(pte_t entry, struct vm_area_struct *vma)
> +{
> +	return entry;
> +}
> +#endif

> +++ b/mm/memory.c
> @@ -2218,6 +2218,8 @@ static inline void wp_page_reuse(struct vm_fault *vmf)
>  	flush_cache_page(vma, vmf->address, pte_pfn(vmf->orig_pte));
>  	entry = pte_mkyoung(vmf->orig_pte);
>  	entry = maybe_mkwrite(pte_mkdirty(entry), vma);
> +	if (vmf->flags & FAULT_FLAG_INSTRUCTION)
> +		entry = maybe_mkexec(entry, vma);

I don't understand this bit.  We have a fault based on an instruction
fetch.  But we're only going to _maybe_ set the exec bit?  Why not call
pte_mkexec() unconditionally?

