Return-Path: <SRS0=jfnU=U6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B22BAC06510
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 23:32:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4D2CC21721
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 23:32:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="yulAQMWr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4D2CC21721
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=linux-foundation.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BF32E6B0003; Mon,  1 Jul 2019 19:32:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BA4918E0003; Mon,  1 Jul 2019 19:32:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A93448E0002; Mon,  1 Jul 2019 19:32:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f207.google.com (mail-pl1-f207.google.com [209.85.214.207])
	by kanga.kvack.org (Postfix) with ESMTP id 7266E6B0003
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 19:32:14 -0400 (EDT)
Received: by mail-pl1-f207.google.com with SMTP id i33so7993842pld.15
        for <linux-mm@kvack.org>; Mon, 01 Jul 2019 16:32:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=O0b2tWO1RIcCmvfvh2lXMb1E+ocfn4SsM4a6s7YsoIo=;
        b=Jxl5jq5PihMQJpIXre5Y8cUDbQr3IkyUI6FfnuoinVJa2CxEl5H2/1q+JhS2coKLce
         I9OdZkzv59CmFyUqskqpOwZyVuBnUH2Q3xBxey1OZYYA/Of2kgj8aF3/MIEiNVOsuNjA
         DydlxhPnn4lO4OOdpuwTJM2EffuS7RDftDmhRYK89dNb2OfUQBJe2CIrmNe2UZkEfCQO
         JhL+X+ohJ09AocaEv6GhHUMs8tQ5VIQd+PuFDHmzFEO5drzXPqvwQlDKb1SP2L1/nCbp
         ++x2jS+HnFwk8JBr/azZ4K/7fdz3aaEpgxVR0CCZEvcKYebap4XQ0L8ItZPCaTQZGumL
         PU8w==
X-Gm-Message-State: APjAAAVikxotHn22ik9nANyWmsBu5B1GL+52GD6kH0UdRdkX4N5c43c8
	ZkHUfDoJEfh2JMAaqvzUjjMYiKqOo6H3WZ7NwxOFDFFNjqpU1O0szQap4HqR/7ylGOjvzW5qmF+
	6EOeOzVP/X52Ojvfgz4GYCL+8eXHeM6xxB+ew184UjouwZ77VgW0aqMBcGvh84Tineg==
X-Received: by 2002:a65:4347:: with SMTP id k7mr27647596pgq.253.1562023933695;
        Mon, 01 Jul 2019 16:32:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx7mo9nf4JHN9faJqize7oD3tsHDo4wLN6RLZF/lOOfeC4r4aQNUYVh1nGl16EM7FfNES+q
X-Received: by 2002:a65:4347:: with SMTP id k7mr27647533pgq.253.1562023932818;
        Mon, 01 Jul 2019 16:32:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562023932; cv=none;
        d=google.com; s=arc-20160816;
        b=UcaXzVlmeZQpTPMUOsRhx2z8pWVOvqv5RcvKnLMe6pb4uXOy+gbjLRBnSbmh5OBTRO
         T9qgBpLJAcLo5+eOqXBvgf5oql/S/7vMABZgejxkc3fX60PwByWENR8W/69jqFFU3nRr
         t6adPs1QXCcV8/SHKsY0YRGUHUW/sHRLS/tpxN6Mkjl+8Ufi9bxD6BeHw87hhzLA8miP
         0hdUGGqsjaUQKXWPEIUgMN+8nDU6xuCLwmDO+/pRDJypWTvd7uCbDO1N5yNaQYUYqV3g
         M4siJlA5+LgeDkLmM4EeEdGBZhJu8fXw9Rd3WUDYdzfIYpKidmOExFx/vDGlhbp64uiY
         H29Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=O0b2tWO1RIcCmvfvh2lXMb1E+ocfn4SsM4a6s7YsoIo=;
        b=uGt7izOPLPge/XeDvjUvmVZ8YH88NhPG1AFT+mUyv88/SdoZBopX2eCYo5UJM0Jth/
         KKh8HpySPh3oGFGjFP1CHc47rIlYdAThC2eKmOh+eAuqtjSPnz/rmzaGjFmUY2t3PbyZ
         9vzfKW4zga1KqV7zuZAcH9yZbopWsCbZtMh9gRtyZEzrvqFkIBdXpFiVQebBjvBukYTJ
         Qb4goMYvThJpjxisvRGbZWToaMNyl8Dr6l24BS2FVL8zvvA/yHVL5DJtG788clTbeRmZ
         7X0Auy+/EHIbasNp9x0Iwh/OTRN0ybkFxUcBcXfpSwNKcO5H9P9ey29ge40x7Sw4MQhW
         RJFQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=yulAQMWr;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id a17si4188382pfa.45.2019.07.01.16.32.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Jul 2019 16:32:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=yulAQMWr;
       spf=pass (google.com: domain of akpm@linux-foundation.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=akpm@linux-foundation.org
Received: from localhost.localdomain (c-73-223-200-170.hsd1.ca.comcast.net [73.223.200.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id E146821479;
	Mon,  1 Jul 2019 23:32:11 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1562023932;
	bh=dBXpbIE1R4CzpTJv8obwrKm6+ibARscFWpAQm9lSQZA=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References:From;
	b=yulAQMWrcw1P+CopEJYaogBfFneJfl2za6FZd5pFA6D5io9m+xQnEm+yQaDWjdT/Y
	 9DFHXlk5mdBoyq4T6dTSKA58o6T74Hd/T8dTqYp/w0HOnpZqf6i5nqYGJuQ9bA1XgI
	 Mo0ZF2H9lZFRsD+XZV8fRh2gemTtyGNq9stOi+ew=
Date: Mon, 1 Jul 2019 16:32:11 -0700
From: Andrew Morton <akpm@linux-foundation.org>
To: Henry Burns <henryburns@google.com>
Cc: Vitaly Wool <vitalywool@gmail.com>, Vitaly Vul <vitaly.vul@sony.com>,
 Mike Rapoport <rppt@linux.vnet.ibm.com>, Xidong Wang
 <wangxidong_97@163.com>, Shakeel Butt <shakeelb@google.com>, Jonathan Adams
 <jwadams@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm/z3fold.c: Lock z3fold page before 
 __SetPageMovable()
Message-Id: <20190701163211.e9e0f2cf5332c06640e3019d@linux-foundation.org>
In-Reply-To: <20190701212303.168581-1-henryburns@google.com>
References: <20190701212303.168581-1-henryburns@google.com>
X-Mailer: Sylpheed 3.5.1 (GTK+ 2.24.31; x86_64-pc-linux-gnu)
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon,  1 Jul 2019 14:23:03 -0700 Henry Burns <henryburns@google.com> wrote:

> __SetPageMovable() expects it's page to be locked, but z3fold.c doesn't
> lock the page.

So this triggers the VM_BUG_ON_PAGE(!PageLocked(page), page) in
__SetPageMovable(), yes?

> Following zsmalloc.c's example we call trylock_page() and
> unlock_page(). Also makes z3fold_page_migrate() assert that newpage is
> passed in locked, as documentation.
> 
> ...
>
> --- a/mm/z3fold.c
> +++ b/mm/z3fold.c
> @@ -918,7 +918,9 @@ static int z3fold_alloc(struct z3fold_pool *pool, size_t size, gfp_t gfp,
>  		set_bit(PAGE_HEADLESS, &page->private);
>  		goto headless;
>  	}
> +	WARN_ON(!trylock_page(page));

If this warn triggers then someone else has locked the page.

>	__SetPageMovable(page, pool->inode->i_mapping);
> + 	unlock_page(page);

and we proceed to undo their lock.  So that other code path will then
perform an unlock of an unlocked page.  Etcetera.

It would be much much better to do a plain old lock_page() here.  If
that results in a deadlock then let's find out why and fix it without
trylock hacks.


