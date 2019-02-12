Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A8F70C282CE
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 14:14:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 666452186A
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 14:14:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="CVwM2ywv"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 666452186A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DEF9C8E0003; Tue, 12 Feb 2019 09:14:24 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D9D658E0001; Tue, 12 Feb 2019 09:14:24 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C40198E0003; Tue, 12 Feb 2019 09:14:24 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 827EC8E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 09:14:24 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id 74so2510681pfk.12
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 06:14:24 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=Z3PSH/hQUVI93YUpUcNoomHE/bQgosJ/DuT/BhSTfds=;
        b=U9tO7SGKz4v9H/ZS87OzpXf5/n+HSxfUmPCTbqzyw/+PwoeiGeQ2AYcBq0ADkofEyO
         NkypQhSNzC33KE/UQF+uCjAoE6xbuezDiZmAE7NGfR1sHAl3cuMf3/Py1m5TK83eElTo
         mKvyLqYcgI2o3ZNUsyWTnX7X6/ZWzS4Z5MOlAdGXc76XB594CbzEwRWHiNcZBRVRwL8+
         lCFHaJPoaaz4OIgrdzfIaHNZdWGRmp1ks1jMUrgXwsclnAn57SgQpXt2Ltrs7vKQBiWj
         n+hzJGgwj9WvwBI/+3dCxtpY7UUOrgSP/72iohvNxf+OZonmaIt+AjsGeUzRtB/1x3b7
         O7Ng==
X-Gm-Message-State: AHQUAub49chJxY84TgctKeG/DCdNmy0w2yquebgf6LKNfI4EtzLXa0ym
	DWtWbIhaXh4D52SUHp0ccqMYHccsuIjV0A6L9G+6eNNTLcIpcyaOe1dEb8bDEldYCdlyipGze/l
	PiYiHDU5RCpHYv92tTHe2fsmtzuARveO2jlYKErIdCCNVRVoUpenv94bXOBM/ntrSkg==
X-Received: by 2002:a63:4706:: with SMTP id u6mr3632190pga.95.1549980864151;
        Tue, 12 Feb 2019 06:14:24 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYifYSkZLSza6Dz+wZI+W4M51pU+o9nt4utTDn1GfwcQFZqdVO8kDv5wyKDOo5qVCuDHcuz
X-Received: by 2002:a63:4706:: with SMTP id u6mr3632141pga.95.1549980863431;
        Tue, 12 Feb 2019 06:14:23 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549980863; cv=none;
        d=google.com; s=arc-20160816;
        b=KfS5xs7/ZF8KCCgSn7s/bDs5Ts7yvnc4UdRT2oTs4tSp/QeGRPIA7y8Q5fW5BOonEp
         yu6R/wvhdCnfgoeg+WywYbQF2Ssl5Mhp6yqx3Lg07wF9RcK9xXygfLLhA0uWLvtcFrCr
         g/sYhiw5mWege6a5HMnmW4f1fcD+I2HBm4MKuhlQYrNqwuPKoHDnWhycrKhJ8PrYwwdd
         aiE2HiJ6T3rCEYarDftGG2O00Lzm7SN2ONTB4E9vcKX76b0mlQgdyij2s/LAkBFyhPVb
         InkozX0KWwHdZQbmFO4Oy8m5Zu1SGC5l9jCC1s1wc29/uzUnToGj1zUrnqICHzrsCZ2r
         z3bw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=Z3PSH/hQUVI93YUpUcNoomHE/bQgosJ/DuT/BhSTfds=;
        b=NJhmdp5yHx5cy5iYtzrz4ktzmR2LgfLd9OzpelYW763AixrkoKZw66rejDJuvHCwuh
         nnCTmk05gnL5MyPImLz9kGhPVjTilwtGNwjFgtESr3Zk2Fj7QZnZ/T2pkktBNZFBZTZi
         L/UzgiuouN8e47TlKG3JX981uMDWE54t9t33HtevPY+TA3kqOYqysXyY99B3LGKO+xoo
         E89JRGcfC4telRkHdCTxAi7WExoBW12HH4eNwZjzECJB4SUOmkyyyuU37U0fq+WLVAcc
         ijWuzUCWWxSPigvayxGU9hxe/sas+8hjkdFUz7Jxqbp4oC5Q1uu0nNg9tz8ncbnEJ+5+
         xsAw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=CVwM2ywv;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id f24si3951764pgb.398.2019.02.12.06.14.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 12 Feb 2019 06:14:23 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=CVwM2ywv;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=Z3PSH/hQUVI93YUpUcNoomHE/bQgosJ/DuT/BhSTfds=; b=CVwM2ywvpI8KyeGTLfXjbpWE7
	B19X7BRbNyhawKIJjcVQ2NcXv+dDtXBKoc1hHQCCXuEeaotm2h3luaYWKEFxmiJrP4AWV9mXyqVbw
	QuNHIZXE+diz5XkMkomcz5zXmmU47Yhh2biVQqIYySAVwQbJXocPWMkrxSa7S0TMSbD8U3oEl7fdg
	n1nKZMS2FFQQlNtKbwmnFD03rbrAmykazflWywB2cFXqIADcr+NC+Zneuzwxc4TzImbwx2H9zlNm3
	kTgadTA2V0Dn04j2JnUgc2xe/RC0qti8yQSHoHeCa6virC0NFp3kOjwA0VaWa7THaaI7Gbwhb5j1m
	T9X8BocZA==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gtYpG-0007rc-Dc; Tue, 12 Feb 2019 14:14:18 +0000
Date: Tue, 12 Feb 2019 06:14:18 -0800
From: Matthew Wilcox <willy@infradead.org>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: "James E.J. Bottomley" <James.Bottomley@HansenPartnership.com>,
	Helge Deller <deller@gmx.de>, linux-parisc@vger.kernel.org,
	linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] parisc: use memblock_alloc() instead of custom
 get_memblock()
Message-ID: <20190212141418.GM12668@bombadil.infradead.org>
References: <1549979990-6642-1-git-send-email-rppt@linux.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1549979990-6642-1-git-send-email-rppt@linux.ibm.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 12, 2019 at 03:59:50PM +0200, Mike Rapoport wrote:
> -static void * __init get_memblock(unsigned long size)
> -{
> -	static phys_addr_t search_addr __initdata;
> -	phys_addr_t phys;
> -
> -	if (!search_addr)
> -		search_addr = PAGE_ALIGN(__pa((unsigned long) &_end));
> -	search_addr = ALIGN(search_addr, size);
> -	while (!memblock_is_region_memory(search_addr, size) ||
> -		memblock_is_region_reserved(search_addr, size)) {
> -		search_addr += size;
> -	}
> -	phys = search_addr;

This implies to me that the allocation will be 'size' aligned.

>  		if (!pmd) {
> -			pmd = (pmd_t *) get_memblock(PAGE_SIZE << PMD_ORDER);
> +			pmd = memblock_alloc(PAGE_SIZE << PMD_ORDER,
> +					     SMP_CACHE_BYTES);

So why would this only need to be cacheline aligned?  It's pretty common
for hardware to require that pgd/pud/pmd/pte tables be naturally aligned.

> @@ -700,7 +683,10 @@ static void __init pagetable_init(void)
>  	}
>  #endif
>  
> -	empty_zero_page = get_memblock(PAGE_SIZE);
> +	empty_zero_page = memblock_alloc(PAGE_SIZE, SMP_CACHE_BYTES);

... and surely the zero page also needs to be page aligned, by definition.

