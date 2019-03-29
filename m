Return-Path: <SRS0=6kLG=SA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2DF42C4360F
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 21:25:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BB6D02184C
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 21:25:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="Y5KuxfJw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BB6D02184C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 57BD56B0007; Fri, 29 Mar 2019 17:25:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 52C666B0008; Fri, 29 Mar 2019 17:25:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 442416B000A; Fri, 29 Mar 2019 17:25:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 24F796B0007
	for <linux-mm@kvack.org>; Fri, 29 Mar 2019 17:25:37 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id 18so3604870qtw.20
        for <linux-mm@kvack.org>; Fri, 29 Mar 2019 14:25:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:subject:from:to:cc
         :date:in-reply-to:references:mime-version:content-transfer-encoding;
        bh=B9AGniAb3nRyLOzlwimHdq/mCOPDCGy4AKCRjTzayXI=;
        b=JeCsmZ9xAmOzRMpL8yaYOMJS1GywyOOz7V2Q+NNDGRGxZFdt3pJclzjySlODJfrRpL
         jlW8AiQWONSR3cfuuwKSqt+CzUo7gUxV/5qKc6pIVCV42EbSKTe0IgQiiugBYooux8ii
         5XVmE56fXNNX7PvQfoxK9AecheTts9VEQfvgLy90bk1gmBbHVJRWeVAsNcnPmdqSgYbh
         UC9zrANT2D4bhogCj3miI2QfoJ1jqhk8t6WelaiYWmZvAxCIdTYAcflg3Eq9KL1+uYk4
         E7bUYPBDkogN2RUz8yvm4IYcX9f5N3io0+Isbx+fGOAklYAqvzjvuXcVlvFiOovT19Bh
         bRbQ==
X-Gm-Message-State: APjAAAU7QyFA8WH127Mm2z7TQsdfKX/7PPaSd6EvTyu+/dKOhYpn13qV
	l18sWpZDq6I2e7FuXddTX8yMAooxGbkP6bbgxey4B7Bvh+n99jO1O3L+9kYXBrO+mwHv3Txu1bp
	ZBjqeH3iLb7xEmkpHgY9StnlyDws7NcQmYztg4Vo5bYDoCFmcyUGiAOCGSRbqX5VPFg==
X-Received: by 2002:a0c:9baa:: with SMTP id o42mr37109034qve.184.1553894736932;
        Fri, 29 Mar 2019 14:25:36 -0700 (PDT)
X-Received: by 2002:a0c:9baa:: with SMTP id o42mr37109003qve.184.1553894736359;
        Fri, 29 Mar 2019 14:25:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553894736; cv=none;
        d=google.com; s=arc-20160816;
        b=0w2ktfJXz2tCQoorYr2PwCh27wFfCEhbA/JdSTJukhSdrLx1gBf963vTsOnvK8kjvb
         SfbkftLumnxVZKyIweQF1yFuWDpLnTH2Ua9VIDEiMKpXOh2yxMmOoLBVFE5CLWUrnBZZ
         Wc586uXMwxtTzdlTNqLbXaMhm8lwU+j3PoAfnNHKgumqMg8YugqK/jdfAptjG+Niigzh
         fo6ft4cv957bNlyrUkwA8QzGQaYLXeADhK2Vzv4TZmAMXMv+0w9O5Vgnk5PpGYz8Uizb
         JSvtyVtjXs3D3yVkxcL8N9y4XqAi2ETejcognB6jdigqxwUv54CZvG2KEuAyc+a501NK
         E19Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to:date
         :cc:to:from:subject:message-id:dkim-signature;
        bh=B9AGniAb3nRyLOzlwimHdq/mCOPDCGy4AKCRjTzayXI=;
        b=0Eupb62JMy6l15iITCVKUr0YCZW52nDH92aDgK5iNPRZ1xwqWy3OP6/oryeB9FDiVt
         TELwbKRjdjtlqzzG3kqVeaoVboupNUILzs6cHWY+LGTYjZ3UWoDdeJ+Z+mfpipqBjUnm
         T0CH93LaVU0ddXuPvTgEDBFKCLMu4pGmk3i+J6c35qma2/Su29lZrXd7WkTmF/p9y4AF
         Gjz28yz8jVOEGADV5gLhuMKxL9/0S5vm9UZdMh+Eq40HSY/lzYHrroIp2hodnS9ukgEY
         mz+tuJGym0B6VYXMIyNiN79hx0V17bTGmKbAmhykkgCcfvEzY+RBSZDUomn6xUieaDGn
         p99Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=Y5KuxfJw;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a199sor1378475qkc.139.2019.03.29.14.25.36
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 29 Mar 2019 14:25:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=Y5KuxfJw;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=message-id:subject:from:to:cc:date:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=B9AGniAb3nRyLOzlwimHdq/mCOPDCGy4AKCRjTzayXI=;
        b=Y5KuxfJw5VfP3MrFhL1aT2+70kt4EosdHc54GwLswRe6m67P5Pj6dcy9McMiblM/Z5
         e+z/+wZ6xPYtuCHncVycDcf3cbwjtfpLigcjBoEjiLF9c65bzRjeeu1c025pHp7zODO7
         UV6svlbpyEUdoiC/KGPhTJyUBpYzaj/eS3KZ7lL8K0SCI2ZKFhMQ1d6/8+s4Ob6YuCKs
         EWcgrmyvGFZZpLBHM3cVfD5Zuc29gNJopTCDaVa9qdzD6EE27YyJorQpD1g7ibmmqaHr
         g19DlPBJjAumX6Tcfjg07TV3+Rb5gJ0XPl9BKjzKxxZfjtZgq7c1qVwETs0a4IvdwTIK
         u+ww==
X-Google-Smtp-Source: APXvYqynCaAKlX00/ja178luKbWIh+PczS6wV4dq8PXeUcGHWJ2h8iwHH7tjRWB+bPv+4UpbCWLcmQ==
X-Received: by 2002:a37:9d04:: with SMTP id g4mr14196078qke.128.1553894736021;
        Fri, 29 Mar 2019 14:25:36 -0700 (PDT)
Received: from dhcp-41-57.bos.redhat.com (nat-pool-bos-t.redhat.com. [66.187.233.206])
        by smtp.gmail.com with ESMTPSA id y197sm1732617qkb.23.2019.03.29.14.25.35
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Mar 2019 14:25:35 -0700 (PDT)
Message-ID: <1553894734.26196.30.camel@lca.pw>
Subject: Re: page cache: Store only head pages in i_pages
From: Qian Cai <cai@lca.pw>
To: Matthew Wilcox <willy@infradead.org>
Cc: Huang Ying <ying.huang@intel.com>, linux-mm@kvack.org, "Kirill A.
 Shutemov" <kirill@shutemov.name>
Date: Fri, 29 Mar 2019 17:25:34 -0400
In-Reply-To: <20190329195941.GW10344@bombadil.infradead.org>
References: <1553285568.26196.24.camel@lca.pw>
	 <20190323033852.GC10344@bombadil.infradead.org>
	 <f26c4cce-5f71-5235-8980-86d8fcd69ce6@lca.pw>
	 <20190324020614.GD10344@bombadil.infradead.org>
	 <897cfdda-7686-3794-571a-ecb8b9f6101f@lca.pw>
	 <20190324030422.GE10344@bombadil.infradead.org>
	 <d35bc0a3-07b7-f0ee-fdae-3d5c750a4421@lca.pw>
	 <20190329195941.GW10344@bombadil.infradead.org>
Content-Type: text/plain; charset="UTF-8"
X-Mailer: Evolution 3.22.6 (3.22.6-10.el7) 
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2019-03-29 at 12:59 -0700, Matthew Wilcox wrote:
> I don't understand how we get to this situation.  We SetPageSwapCache()
> in add_to_swap_cache() right before we store the page in i_pages.
> We ClearPageSwapCache() in __delete_from_swap_cache() right after
> removing the page from the array.  So how do we find a page in a swap
> address space that has PageSwapCache cleared?
> 
> Indeed, we have a check which should trigger ...
> 
>         VM_BUG_ON_PAGE(!PageSwapCache(page), page);
> 
> in __delete_from_swap_cache().
> 
> Oh ... is it a race?
> 
>  * Its ok to check for PageSwapCache without the page lock
>  * here because we are going to recheck again inside
>  * try_to_free_swap() _with_ the lock.
> 
> so CPU A does:
> 
> page = find_get_page(swap_address_space(entry), offset)
>         page = find_subpage(page, offset);
> trylock_page(page);
> 
> while CPU B does:
> 
> xa_lock_irq(&address_space->i_pages);
> __delete_from_swap_cache(page, entry);
>         xas_store(&xas, NULL);
>         ClearPageSwapCache(page);
> xa_unlock_irq(&address_space->i_pages);
> 
> and if the ClearPageSwapCache happens between the xas_load() and the
> find_subpage(), we're stuffed.  CPU A has a reference to the page, but
> not a lock, and find_get_page is running under RCU.
> 
> I suppose we could fix this by taking the i_pages xa_lock around the
> call to find_get_pages().  If indeed, that's what this problem is.
> Want to try this patch?

Confirmed. Well spotted!

> diff --git a/mm/swapfile.c b/mm/swapfile.c
> index 2b8d9c3fbb47..ed8e42be88b5 100644
> --- a/mm/swapfile.c
> +++ b/mm/swapfile.c
> @@ -127,10 +127,14 @@ static int __try_to_reclaim_swap(struct swap_info_struct
> *si,
>  				 unsigned long offset, unsigned long flags)
>  {
>  	swp_entry_t entry = swp_entry(si->type, offset);
> +	struct address_space *mapping = swap_address_space(entry);
> +	unsigned long irq_flags;
>  	struct page *page;
>  	int ret = 0;
>  
> -	page = find_get_page(swap_address_space(entry), offset);
> +	xa_lock_irqsave(&mapping->i_pages, irq_flags);
> +	page = find_get_page(mapping, offset);
> +	xa_unlock_irqrestore(&mapping->i_pages, irq_flags);
>  	if (!page)
>  		return 0;
>  	/*

