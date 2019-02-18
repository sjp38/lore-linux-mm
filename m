Return-Path: <SRS0=YQJ0=QZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A46C3C43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 17:52:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 615162173C
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 17:52:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="EHo5dniL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 615162173C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0073E8E0003; Mon, 18 Feb 2019 12:52:29 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EF8148E0002; Mon, 18 Feb 2019 12:52:28 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DE8958E0003; Mon, 18 Feb 2019 12:52:28 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9F5838E0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 12:52:28 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id f5so12474247pgh.14
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 09:52:28 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=g2UasSOVduo4Pn1t6looKIhYnzUquXamY1qe8zmaCUs=;
        b=aW4HEok6sGVL7AffSRJxLTvtdZ5gRa+XpV+QezN25gfmZbhWkJ5oeuDoEjqNrqL3+/
         ALavplAyYif72jO7bZbH9En52JmCmJCJQK6Jf0ylA/pZl8AzNBkq9uWM+S8Q9uPI0QNB
         6bOz2i9vkyvgvbm0XBKd/BkmxO9O7/FHtsVQ4gXX1H3CdBi/R6k5Rvqwx+T4IbrzfDI1
         82FtRAvGBYP3EW0I+HIF78fRVaa9X4JqZvHi9sbXuux6IRJSomSobQTD3A0Rr2LjP3SZ
         gxaXDac/0BPNZfdt8MC/2Lgo1H9O609T0mxXaAVeY/xv6AC9I9YXYkmkczeXL11Wm+3s
         RYwQ==
X-Gm-Message-State: AHQUAuZB7kZ8VuJwMjNhwtnhcYNPguoGmqgUhcntrD9CTCh/J/yMPRJ7
	7wcJuCw/q8SqI7pHg9l2tVNZPsnh1+Y6LthECSjwfwRX5l0T4SNslvSxyHyC8DHECDplB0IPLcq
	leL8CWhNXKoDplrQBP/mLUdOJX9s5GPrTYnZlkwvIW6PbBfXnop5YLZS4C/Gn7YiDvw==
X-Received: by 2002:a63:d814:: with SMTP id b20mr20164869pgh.312.1550512348280;
        Mon, 18 Feb 2019 09:52:28 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZ9mbjsES8dhNumKsWYlKOLIR8rlD+WmYzbkebB01Jx4/6WH8Iwohg6KW3IaGk9F1DCC3mN
X-Received: by 2002:a63:d814:: with SMTP id b20mr20164837pgh.312.1550512347634;
        Mon, 18 Feb 2019 09:52:27 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550512347; cv=none;
        d=google.com; s=arc-20160816;
        b=U/hE3PQvmG3HTqTyXka1XiwxnXu07kA2NqXV5j0givwtHPeann723oRhjm3f7LQOBQ
         cYEcSvUrk8Dx1y6kvRPv6zAlXEgVGc67+dzT2HWkQ3x4QMmztAvinOKe3LJ9EZRuywW0
         fHzR1GcZM/cMqe5Xa0zGODBbOjPvTnJBF58+2f7SbD3oIZ63fsg+iDHl674w+8Z4fu2b
         jzoKABYDfy0LSxjgeYwtgdigLCSRRpqvoKPUEyUpd0VRKp2D6i5ubEdDtAyia5d3CGLd
         ogL9olx/JNc54b8z7ZIpwmBbhjZ1MheJamZR2p720JtyUF4bBb+Id5AUke0pGnE4noNj
         WPIw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=g2UasSOVduo4Pn1t6looKIhYnzUquXamY1qe8zmaCUs=;
        b=RNjB57/2yjfoz2o+V32sj/p0bVY7SpqfTLQpY2JB2d8t6ySEs9eD+z989FSIbK3wCF
         i0yfkNie0E2AvamjAU7/ggv+36Fv/O/yZmUTCiwJD7ic0CRZt8B4HUGOt4CNNeC4WZAC
         30eOCOxwnH2onIhZV0Bm2fUKlKZFNrfGUx//nuL3j3rKWF6pcwEIxUyZllZi+oLRWssU
         brKPUzJLBXncF1wIXBaLyk/+kfNp5W9t2CXkFSvpZOgO0jf+QSQlKCuOht5ITm9AzMdM
         Jy9T/e4CZfBAGr921yvpNpHeBzoAqnatqGnnRXUFIEyqh2seldG4mt2tvnuUgKRMV+mK
         /nvQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=EHo5dniL;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id w15si14955744plk.357.2019.02.18.09.52.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 18 Feb 2019 09:52:27 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=EHo5dniL;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=g2UasSOVduo4Pn1t6looKIhYnzUquXamY1qe8zmaCUs=; b=EHo5dniLrM/vmG3M0pRQk566g
	4qKO4CXsRCLz5jjir8alD/8vEmVbKNo549TgKV64dx7kyjb2ivG7X+dX9m9bpeG0PDZCVKi+ZEh+y
	1+H8QLqSKkHnToZ8DnrlDK7AfXTR71F516hZ4X5ei0TlLZV2WbkrXhXP88a/y1G0ACwV4ivkKLtqb
	LZyqUCP4tC9i1O1dSCgvD+mrl0+0+nm/wKVi2GSRSk5QW0dJA+tUbDpJSdNP8bb4gXPA5xzIJKtKx
	H0/EquC/MBVd7elx6AnapGJ0MdBHBRjKQmSBx+9ygzNU+ImdcGwi+9nfMAXHYzvitGu8q5a/1ffkN
	dUzf7qjgg==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gvn5d-0000Zt-4c; Mon, 18 Feb 2019 17:52:25 +0000
Date: Mon, 18 Feb 2019 09:52:24 -0800
From: Matthew Wilcox <willy@infradead.org>
To: Zi Yan <ziy@nvidia.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Michal Hocko <mhocko@kernel.org>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Mel Gorman <mgorman@techsingularity.net>,
	John Hubbard <jhubbard@nvidia.com>,
	Mark Hairgrove <mhairgrove@nvidia.com>,
	Nitin Gupta <nigupta@nvidia.com>,
	David Nellans <dnellans@nvidia.com>
Subject: Re: [RFC PATCH 01/31] mm: migrate: Add exchange_pages to exchange
 two lists of pages.
Message-ID: <20190218175224.GT12668@bombadil.infradead.org>
References: <20190215220856.29749-1-zi.yan@sent.com>
 <20190215220856.29749-2-zi.yan@sent.com>
 <20190217112943.GP12668@bombadil.infradead.org>
 <65A1FFA0-531C-4078-9704-3F44819C3C07@nvidia.com>
 <2630a452-8c53-f109-1748-36b98076c86e@suse.cz>
 <53690FCD-B0BA-4619-8DF1-B9D721EE1208@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <53690FCD-B0BA-4619-8DF1-B9D721EE1208@nvidia.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 18, 2019 at 09:51:33AM -0800, Zi Yan wrote:
> On 18 Feb 2019, at 9:42, Vlastimil Babka wrote:
> > On 2/18/19 6:31 PM, Zi Yan wrote:
> > > The purpose of proposing exchange_pages() is to avoid allocating any
> > > new
> > > page,
> > > so that we would not trigger any potential page reclaim or memory
> > > compaction.
> > > Allocating a temporary page defeats the purpose.
> > 
> > Compaction can only happen for order > 0 temporary pages. Even if you
> > used
> > single order = 0 page to gradually exchange e.g. a THP, it should be
> > better than
> > u64. Allocating order = 0 should be a non-issue. If it's an issue, then
> > the
> > system is in a bad state and physically contiguous layout is a secondary
> > concern.
> 
> You are right if we only need to allocate one order-0 page. But this also
> means
> we can only exchange two pages at a time. We need to add a lock to make sure
> the temporary page is used exclusively or we need to keep allocating
> temporary pages
> when multiple exchange_pages() are happening at the same time.

You allocate one temporary page per thread that's doing an exchange_page().

