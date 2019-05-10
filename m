Return-Path: <SRS0=iTus=TK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 32D2EC04A6B
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 16:36:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E918321479
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 16:36:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="aa7n+JxO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E918321479
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 72E346B0003; Fri, 10 May 2019 12:36:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6DDBE6B0005; Fri, 10 May 2019 12:36:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5CBF76B0006; Fri, 10 May 2019 12:36:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 26CBE6B0003
	for <linux-mm@kvack.org>; Fri, 10 May 2019 12:36:22 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id q73so4472838pfi.17
        for <linux-mm@kvack.org>; Fri, 10 May 2019 09:36:22 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=b/JhnmzdXvcZzBwouxXoQxGy1LUWG9vrwQ6s+nGq3oI=;
        b=KWVSNVc7W+3zv5sspFp7AWf2tQYmbczAmPsqXoStixqLHXH+3VJBdaAobVNLubWGwt
         KxDiiNDVPVP4O/OHpLmdij4/atADTrT9fIgEDID01mPreV9HcvHlQn+kIqbh0FR6P09z
         vMP721THL0w40wijS2OttFpc3fyqFpMaFFnMggxpqm57RAUjo8cJeBer2QBvdq6GmHEQ
         DRrhlmdbtoMhHu/NnXeoAdA6P/fIKPyKLB2+pO6reOVqBfjotmCuiW941QrtlikBqx/Q
         WBk9IuPq4I+/9wztALXM0a5UGa+0XNIpYhca1bIPoA0dlvc1i4hNB5zvN/ECPPzNT7sq
         BiKQ==
X-Gm-Message-State: APjAAAXDa/aY4wH4wZ+FhuY1SnZMGAjKX45wyIl8OI8Z/1C57iecJHB+
	RDSfmVEkOo1ti0ZRjqam6sLTXoN5kUGbL2GwzPg3dBz9Q+l/PNTvYuXGBXAZr5iQK3lTYzIHlaC
	8B2a6mICBihRXf9qmqxjA2+4+KEFTBBN+TjVR1Srp36KVHsyTDJ93Xct6qFP5yOUQgg==
X-Received: by 2002:a17:902:b181:: with SMTP id s1mr14627196plr.9.1557506181768;
        Fri, 10 May 2019 09:36:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx+xh2yAS3bHy6iuw2g8xFrnUxq3r+7C9RXLwCe6ptaTCC87LL+IK/8HlaRe69I538C5Qqf
X-Received: by 2002:a17:902:b181:: with SMTP id s1mr14627124plr.9.1557506181130;
        Fri, 10 May 2019 09:36:21 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557506181; cv=none;
        d=google.com; s=arc-20160816;
        b=k2Q3z1H2N6JA+MeSlvWa/yh8lCkabjRRBFXyX+DQFXPvBRvjxFnQBaIFF6z9bj3uEN
         dC6Us56sgHz9Sf6WwGVo+e8EMwbifODno9+qy4G4XyhwkUAB5nmAxOXky0wa8aMhobsZ
         xPO1o3DccnEi0RtJiWGm8lwRs+OstmMkm1qFpXtWSEiTM+cbNm2jCJv/da0vATVp62eM
         YYA0ig4YsW5Wz/GRYD88Bkq57lucVfdVxPVtk2afZxGPz2j8mlp3W5QLyh9LrHwiM/F6
         NVw4qOZtWTClrWyW68rrhPcrVS7kQJmKtmdQwq6XQMb/AaBzxHdeZ5IFDg7wfy1AWHZv
         rPhg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=b/JhnmzdXvcZzBwouxXoQxGy1LUWG9vrwQ6s+nGq3oI=;
        b=0q9CMoaG/vyIyj7pcFSXV9obeKxvJXDP6hu9VCdV7fH6TAMHJXD3TemPlfc7GbR28+
         WRK/+onyad+A5x1tayaIfvR2HJJ5x5CRLYrvgFjsMeOckCqcOYqbT9GNgdTK+MD9rNR5
         quLmd7MUDwNWtNEQo3gwiWWahI5kr1mL/f5R77ifbcRZPPo+GxmJpLtMFrAOKqCvY79m
         sCKTScSurGqwTp0H7XO6sTzU7kX11Nbep6q6xf7YSCLqPUPHpIV6R1dYQSW8EyoC6nJb
         yH8a3Ysf73rinsCwMQYjnUt53KUm1avUMPvjXMUsV/trDftBEYn8KTIV9+VoCfcapni9
         bfTA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=aa7n+JxO;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id q8si9000097pgf.3.2019.05.10.09.36.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 10 May 2019 09:36:21 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=aa7n+JxO;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=b/JhnmzdXvcZzBwouxXoQxGy1LUWG9vrwQ6s+nGq3oI=; b=aa7n+JxOP4GJyt+6e9t186rvV
	ZLNOAx0QcDgAMax2GMB3YAFR2nvjovRMNFHsqMoqrw7bksP5Q8t57AlEyhctFD8PzdKtfIZxNHlhk
	BrX2diNGkIneThNr0j/li+YDar0K9CwzwSzMjRNI7W+Txv4AWT/oCeGKEGoBxCafblJbgmvzstPVA
	30TskXHyRLMWWBNBqfYi9PHfso3dkPLNR5XffHnIz7m43cbLaBTst9Kf/A9/zzwKrOG2FJqqc30DE
	YXtWqLHH6vgBfoqm12GBjjebNEbUh6DPDhKHlp48pY78sCZhOkd4aV3aHiXiSQcBrDo9Uyo4bZNRj
	uw3aSHlXQ==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hP8VJ-0007RN-1p; Fri, 10 May 2019 16:36:13 +0000
Date: Fri, 10 May 2019 09:36:12 -0700
From: Matthew Wilcox <willy@infradead.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Yang Shi <yang.shi@linux.alibaba.com>, hannes@cmpxchg.org,
	mhocko@suse.com, mgorman@techsingularity.net,
	kirill.shutemov@linux.intel.com, hughd@google.com,
	akpm@linux-foundation.org, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] mm: vmscan: correct nr_reclaimed for THP
Message-ID: <20190510163612.GA23417@bombadil.infradead.org>
References: <1557447392-61607-1-git-send-email-yang.shi@linux.alibaba.com>
 <87y33fjbvr.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87y33fjbvr.fsf@yhuang-dev.intel.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 10, 2019 at 10:12:40AM +0800, Huang, Ying wrote:
> > +		nr_reclaimed += (1 << compound_order(page));
> 
> How about to change this to
> 
> 
>         nr_reclaimed += hpage_nr_pages(page);

Please don't.  That embeds the knowledge that we can only swap out either 
normal pages or THP sized pages.  I'm trying to make the VM capable of 
supporting arbitrary-order pages, and this would be just one more place
to fix.

I'm sympathetic to the "self documenting" argument.  My current tree has
a patch in it:

    mm: Introduce compound_nr
    
    Replace 1 << compound_order(page) with compound_nr(page).  Minor
    improvements in readability.

It goes along with this patch:

    mm: Introduce page_size()

    It's unnecessarily hard to find out the size of a potentially huge page.
    Replace 'PAGE_SIZE << compound_order(page)' with page_size(page).

Better suggestions on naming gratefully received.  I'm more happy with 
page_size() than I am with compound_nr().  page_nr() gives the wrong
impression; page_count() isn't great either.

