Return-Path: <SRS0=aXoD=SR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5BC5FC10F13
	for <linux-mm@archiver.kernel.org>; Mon, 15 Apr 2019 02:24:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1A2B120848
	for <linux-mm@archiver.kernel.org>; Mon, 15 Apr 2019 02:24:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="fq0EfNQX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1A2B120848
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9B8146B0007; Sun, 14 Apr 2019 22:24:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9644A6B0008; Sun, 14 Apr 2019 22:24:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 87B0B6B000A; Sun, 14 Apr 2019 22:24:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4CE5D6B0007
	for <linux-mm@kvack.org>; Sun, 14 Apr 2019 22:24:25 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id p13so10430354pll.20
        for <linux-mm@kvack.org>; Sun, 14 Apr 2019 19:24:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=aB6g0E//NkNVlipKG0sOhrOyS6Dw+DkFuHN89+1UXTY=;
        b=oqLXZfWpB0sJwbB/TXHK7QqPpg0PZ5HKAv6otJXsh3CaX3XO9JDvA6Fq/6xV5O3ej2
         iy8suawa9uLzr9HUrE6dRUw0mzyhAmgfFDE61e18ZH02MToj7d5GV6mT8NcyJAgWgBW5
         BOnVNPVREOpjcF2/lvz2SHyn7p+JwIXE3fQzq01er+9zls35WYyJeq6zPRYTx3oF/g/M
         WOmuoULKLOLIAGVkT0+XEvTSrt5xBJCZ5WHxa9tv8KQoblebmG93eq5IetVQZtgmPDRO
         c1fYW5R9FvcIBA0tAZA+PLL+hnInlAkBsPE3wt0JkEOnikHeSrn3qLz0u2dYqUqAoDM6
         mSZw==
X-Gm-Message-State: APjAAAWrSsRER+nTmx3HMPy+IO1c45bzROFkwER0Q6ogVlcGDt2FhPP3
	fdTdF0gujVtuOcp/+kakVeO9hdM4q4uPRF8K+9tYZmSe6HiYPhB+lp1PlMWs115mhovvxmkgR+n
	RRmQPm/7hQKVfyxVVnmq8SBfua2Wtsevq05xcchzX/lUxHYbxlUewD5bsrSmvOmn/Rw==
X-Received: by 2002:a17:902:6b03:: with SMTP id o3mr72670680plk.226.1555295064646;
        Sun, 14 Apr 2019 19:24:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxCwZ1UX8YRuXVAQTj1B4Rufx2ZmHyWH4qY+g+J6Ml//jJbytTqX99Xrc466WF+0rol/PZz
X-Received: by 2002:a17:902:6b03:: with SMTP id o3mr72670639plk.226.1555295063954;
        Sun, 14 Apr 2019 19:24:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555295063; cv=none;
        d=google.com; s=arc-20160816;
        b=oTaIDb9cl88M4ma/gT7UDpi4PSeB3hCODj+ySmLzrgiz7GsA4l709WZkHRLKaXMksA
         5nLdLHHfzd4gFGRmIIbzuN46GOshZT5RPRrskpM3eHaUnu9IgBkpcbG4RwvPFtQy8e8o
         GKZK6X2u3Bg3Lkgp9T0xp1aW5LWsNq7CXWerQmqJ/Kg66fpdu41c57koyAVAIgaocRzd
         bBWEtt7gWOlVsxvbwklIGB8AdyD3p8GitHaMQ0UgwL+KkieUXyxYHODc5+w9VW643JnW
         8ulMq5zz9xE3RhF8hPwLvP9cc+pnDRMBN+sH9IOUSQDb67Nqz5mDPGFdY5xAcE6XWruy
         6acw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=aB6g0E//NkNVlipKG0sOhrOyS6Dw+DkFuHN89+1UXTY=;
        b=OqLPldQGREJh9K+eeCQaXGo/Sok8hAKOcZe7llkQfX5YZ8fJE+h7djtOKyGs3Bv36x
         IZneXdpqSbeWni1X5DEBL3fWg5fNvkKdhZjae4uSkND4chVbq8KWtgTY0Bx+HCdSQK4h
         sl15o2Ec9qUMzHjMpGzeUm7u+Mv4ndUiK+Y8/hk41KddzUMTFKGejKTAO37TgNmItO+m
         SP0gaOxRKCe0Hv86WmyH8+XiHigV85HfVwJAccQsyhLn1I/tccYMLswJqz8r9Z1sGrFS
         7cboBFp0wS5TE2LTzG3KktCcd+kjkd+yPgZzA0IVu6UDQKt+S8jr2oZMJ5PuWJjQXJ5X
         SuxQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=fq0EfNQX;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id i11si45305532pgj.46.2019.04.14.19.24.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 14 Apr 2019 19:24:23 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=fq0EfNQX;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=aB6g0E//NkNVlipKG0sOhrOyS6Dw+DkFuHN89+1UXTY=; b=fq0EfNQX5nmmKBJBSToMWL+EU
	FxkpnJG2cnRAHFxr+1W/jqEJiVT7FnrH9KpPttGpFx/T7D9QeyyP6ORiCBXLzW0CSHJgygexR8OEv
	LGgRxRk6rGqLCiZ7KvkazpzS3Ut3DXqH6MarjmuEo/wxSBFEb4VLhMJFLX2C6dc8tHn3KZ57MypRf
	c2AG1z6qj6Gzc7hj5pNwfP3/xYm+JbK/igIaiG/xhkuvqKjv3NBQNiY/SumzLQQ7HXAPm7ggHF4Go
	ds5GKrGU3C1kVsilweVs8h7utQitrg4S1CeaHlkJaGpFenphFG+mPP5NG7MCoitqRzYgwVPBWPZ+E
	cpkaKGf7g==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hFrI4-0005Pf-K4; Mon, 15 Apr 2019 02:24:12 +0000
Date: Sun, 14 Apr 2019 19:24:12 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Kees Cook <keescook@chromium.org>
Cc: Eric Biggers <ebiggers@kernel.org>, Rik van Riel <riel@surriel.com>,
	linux-crypto <linux-crypto@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Dmitry Vyukov <dvyukov@google.com>,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	linux-security-module <linux-security-module@vger.kernel.org>,
	Linux ARM <linux-arm-kernel@lists.infradead.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Laura Abbott <labbott@redhat.com>, linux-mm@kvack.org
Subject: Re: [PATCH] crypto: testmgr - allocate buffers with __GFP_COMP
Message-ID: <20190415022412.GA29714@bombadil.infradead.org>
References: <20190411192607.GD225654@gmail.com>
 <20190411192827.72551-1-ebiggers@kernel.org>
 <CAGXu5jJ8k7fP5Vb=ygmQ0B45GfrK2PeaV04bPWmcZ6Vb+swgyA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGXu5jJ8k7fP5Vb=ygmQ0B45GfrK2PeaV04bPWmcZ6Vb+swgyA@mail.gmail.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 11, 2019 at 01:32:32PM -0700, Kees Cook wrote:
> > @@ -156,7 +156,8 @@ static int __testmgr_alloc_buf(char *buf[XBUFSIZE], int order)
> >         int i;
> >
> >         for (i = 0; i < XBUFSIZE; i++) {
> > -               buf[i] = (char *)__get_free_pages(GFP_KERNEL, order);
> > +               buf[i] = (char *)__get_free_pages(GFP_KERNEL | __GFP_COMP,
> > +                                                 order);
> 
> Is there a reason __GFP_COMP isn't automatically included in all page
> allocations? (Or rather, it seems like the exception is when things
> should NOT be considered part of the same allocation, so something
> like __GFP_SINGLE should exist?.)

The question is not whether or not things should be considered part of the
same allocation.  The question is whether the allocation is of a compound
page or of N consecutive pages.  Now you're asking what the difference is,
and it's whether you need to be able to be able to call compound_head(),
compound_order(), PageTail() or use a compound_dtor.  If you don't, then
you can save some time at allocation & free by not specifying __GFP_COMP.

I'll agree this is not documented well, and maybe most multi-page
allocations do want __GFP_COMP and we should invert that bit, but
__GFP_SINGLE doesn't seem like the right antonym to __GFP_COMP to me.

