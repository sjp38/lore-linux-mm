Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AACD0C282CE
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 16:55:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4AD6121B69
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 16:55:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="meLlPrrc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4AD6121B69
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AFBBD8E0101; Mon, 11 Feb 2019 11:55:58 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AA9B68E00F6; Mon, 11 Feb 2019 11:55:58 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 998788E0101; Mon, 11 Feb 2019 11:55:58 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 573058E00F6
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 11:55:58 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id l9so9810660plt.7
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 08:55:58 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=zbMt34Xljo5tjtnZs6T2V6O0BM0gQZ6UPbqfhLadqyY=;
        b=pPJq3+tRbz0DHdMwjoHWBDB7Z7NnI5bW9jfqyDKSTaA8KC3uEhOrXo7mTu0ano6at+
         loV6xFa3HcNpOyVgOa5VHFc9I349EhG8aTx7QmQj5601Uakz3w+LDwRUIQrWLoGi+ihv
         17kA0L3ZVg5kbmHp9s6N7n4DttluXQQdLMq9c2phI+u6+v1oZw34s5UUxilk8r+Lwrw4
         L7whnsGIcS9E7SjzmKTNncA+CDsRob2fAuMWtap1J8O2LjRZ4h2B3wkL1rFsIWPecFnF
         Z95SXZgxpuPzvVEcoX5Igdm/nh5Y5ghpEVSOh9aW0aiOT4OxtqB5eA6MJiwzJznfqDb/
         avow==
X-Gm-Message-State: AHQUAuZjJ5byoe7QZxLaD8C/klBCAMAVIZUExcGSt7Tu6nB4/kbaEIrD
	fFNzjIG4R/dKPRPJ6xMwtbRBz5Trt/e1gIyZLlAG8NkVU7RDfOTUIW6Feg1WhNwMm0OOG1fTZvx
	mhPNRhDIja7LzWdJAYqgW0D3VyzTQabkYm37hAFahsPyyKsYXD3yqR68izinMMvEIJA==
X-Received: by 2002:a62:5007:: with SMTP id e7mr37702796pfb.92.1549904157960;
        Mon, 11 Feb 2019 08:55:57 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZhvDbNIWMaik+jCRAdoUVtIeVYrHtugsihtNSXyhHFm9t0za4BdsveSPL7hqd3KSkNBXb4
X-Received: by 2002:a62:5007:: with SMTP id e7mr37702709pfb.92.1549904156823;
        Mon, 11 Feb 2019 08:55:56 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549904156; cv=none;
        d=google.com; s=arc-20160816;
        b=s5XB3o/tX2y/Av+du5O+jLxkkPVJifEx1wMEhoCp0AeMbRZB0MzJ7636bjn8Nm17po
         2H/8MwCc5678xcDwxoOtiCiaPb6iM7GDWPhDxKU4sNgd3KH9g8x6w3g2wYED3hQwVjrI
         OTOU9Wd4K2w6wSr1td7tVCbTZwlkU/ImJra/DYUchmut0oDbdHuDXCZD0SEWsy3O/klq
         Q7qd19cOdj5hKWduezdfmeoQy56tPgomEKUB0aRxud26nf9/lUnY9fWjmFoipzgHEMh2
         ZVctAdAXcYYegtCLzIsb8itRgCk15wkZkO0hPtHWAPKEXK47PKjJ8w2/3qRdnSPTohit
         ViNg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=zbMt34Xljo5tjtnZs6T2V6O0BM0gQZ6UPbqfhLadqyY=;
        b=LsCzMhTHk7M2VF/aLPs09lRuJAxAL/PY6hHGXegFiYB+4Ng/+o/AP5WJuye17uWelo
         vW3m/o4IMe381QqeKN78YrySsQZxCWr4gu6ne/y/VaFXI9lAoF646jUetgvP071bh4d7
         FAjNUa0NU3UD9KvctJy9Z1cgWcIIjPE9ID/5Fcnxp0tNlQabxYNHzNAzfEMbsHlkdx7G
         3oNMgZjuDPftZy9dD5iZi0/wJH0lkxiuHiyWJuNQudqWHLaSEsMvwyvk9/PSxda5dEjw
         I/vDTcfIlKmqLcY/4tRIkxzY+5Q+PMUwNJofac/x/QAlI4gS6OhF3oXJ3v3dirbE/CpM
         3w+Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=meLlPrrc;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id s27si9841629pgm.501.2019.02.11.08.55.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 11 Feb 2019 08:55:53 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=meLlPrrc;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=zbMt34Xljo5tjtnZs6T2V6O0BM0gQZ6UPbqfhLadqyY=; b=meLlPrrcbD0W5cDENE78HJ+4o
	dtH/1NCZ0Gh5bIeC+NKM2zQ2Tata/DOmGOb8GjoCaBxVrbIJ11+CrMz76ziXqDNJquy/zgfmbkOYZ
	+pQXKYz+xIKZWGYD/RE5xSQkH2Q0SisQVd7ZcmjjunIgA0oPpYvZKQTQzDzLdv3bwqbXz1/ol5pNm
	lKo8G+Km9tpc+4iOHw87G++qquxd+G39RBqaMjPUip/x2chOdA+p0RcYAZew1Cr+THkEy8dOOVCFI
	7b80sWpcsuirYhAP7jXJjghw/wPdn+iYGuQL9x3dNlI5kVUbKJkSqk8+372dOTsJm39+w4VKtaA4a
	sWSZNifbw==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gtEs3-0006aE-Ap; Mon, 11 Feb 2019 16:55:51 +0000
Date: Mon, 11 Feb 2019 08:55:51 -0800
From: Matthew Wilcox <willy@infradead.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: netdev@vger.kernel.org, linux-mm@kvack.org,
	Toke =?iso-8859-1?Q?H=F8iland-J=F8rgensen?= <toke@toke.dk>,
	Ilias Apalodimas <ilias.apalodimas@linaro.org>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	mgorman@techsingularity.net,
	"David S. Miller" <davem@davemloft.net>,
	Tariq Toukan <tariqt@mellanox.com>
Subject: Re: [net-next PATCH 1/2] mm: add dma_addr_t to struct page
Message-ID: <20190211165551.GD12668@bombadil.infradead.org>
References: <154990116432.24530.10541030990995303432.stgit@firesoul>
 <154990120685.24530.15350136329514629029.stgit@firesoul>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <154990120685.24530.15350136329514629029.stgit@firesoul>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 11, 2019 at 05:06:46PM +0100, Jesper Dangaard Brouer wrote:
> The page_pool API is using page->private to store DMA addresses.
> As pointed out by David Miller we can't use that on 32-bit architectures
> with 64-bit DMA
> 
> This patch adds a new dma_addr_t struct to allow storing DMA addresses
> 
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
> Signed-off-by: Ilias Apalodimas <ilias.apalodimas@linaro.org>

Reviewed-by: Matthew Wilcox <willy@infradead.org>

> +		struct {	/* page_pool used by netstack */
> +			/**
> +			 * @dma_addr: Page_pool need to store DMA-addr, and

s/need/needs/

> +			 * cannot use @private, as DMA-mappings can be 64-bit

s/DMA-mappings/DMA addresses/

> +			 * even on 32-bit Architectures.

s/A/a/

> +			 */
> +			dma_addr_t dma_addr; /* Shares area with @lru */

It also shares with @slab_list, @next, @compound_head, @pgmap and
@rcu_head.  I think it's pointless to try to document which other fields
something shares space with; the places which do it are a legacy from
before I rearranged struct page last year.  Anyone looking at this should
now be able to see "Oh, this is a union, only use the fields which are
in the union for the type of struct page I have here".

Are the pages allocated from this API ever supposed to be mapped to
userspace?

You also say in the documentation:

 * If no DMA mapping is done, then it can act as shim-layer that
 * fall-through to alloc_page.  As no state is kept on the page, the
 * regular put_page() call is sufficient.

I think this is probably a dangerous precedent to set.  Better to require
exactly one call to page_pool_put_page() (with the understanding that the
refcount may be elevated, so this may not be the final free of the page,
but the page will no longer be usable for its page_pool purpose).

