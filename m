Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 03D60C04AAC
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 01:45:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B28032173E
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 01:45:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="q4yLHaP0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B28032173E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5CFC96B0005; Mon, 20 May 2019 21:45:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 57FFE6B0006; Mon, 20 May 2019 21:45:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 472836B0007; Mon, 20 May 2019 21:45:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 10EBB6B0005
	for <linux-mm@kvack.org>; Mon, 20 May 2019 21:45:01 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id x5so11188765pfi.5
        for <linux-mm@kvack.org>; Mon, 20 May 2019 18:45:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=H2+x+MHVEZdCVE43yCMhl0CBsWPnqAGcA3mpEfmYBV4=;
        b=izUw5gglXnzASEdkZhYFw+HBMBzZKpCwxra+sqAnclFP4nyhFr1qr3MlAc6mYtdq5d
         3rbbs/QK6tkMOVaqJMjGegJ5nqc2nmuiq9uCXPbBzJjFxiZz90qpD6bb+qiuSAXohMhT
         /gQfRBHULFCqIvLWiIiRKPSSpxAP+izRpKZQa4Chg5kTRf1EjdJz46fU71DZHsw3kZs8
         Ec1qxpbR8jiQp+IQD+oUD57zJqnmugc9QcOMGlPb2uynzn74UdtjNuzoLluNghGbZi8W
         /tZW5eaGsR7puiLG2JsVYWjofwrQQL7o4VlPr4HEd4yEwDJI2LdCfw0WMs4PHxzjWNKg
         clwQ==
X-Gm-Message-State: APjAAAV4n/753vWVXWCxIvPBEi0gME8kDBC5IoEAoehH0Lyd7My5Du9H
	R/uftI7u9Z8OOwC2kFXTxYENzUytdK5t+a1U/XeHkeSNVgPTY6lOR/i5EcybFN2KnRXcuyLC87f
	P1UNaieDWXB9E1cJFY2zjKyhC+sKmZCUlaQ8SYngFh1wopGxZFX39wkqk6iATzG1y9A==
X-Received: by 2002:a63:2cc9:: with SMTP id s192mr36224302pgs.24.1558403100687;
        Mon, 20 May 2019 18:45:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy4Z27GfOyCuCOJC3ck8km5xsf4BMZaJb5WsmW0OUlJM4OpgwHT/zWIPoYqLvHUnmNyGtCM
X-Received: by 2002:a63:2cc9:: with SMTP id s192mr36224255pgs.24.1558403099996;
        Mon, 20 May 2019 18:44:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558403099; cv=none;
        d=google.com; s=arc-20160816;
        b=NNd/kCNFqL9QsmWtaLix4H9ghzZDTG24xX9fKphRuQic6LVmMJx8Pkb5dIjbnotPRE
         zyTaP/3g8tbjGu7Zpgn+IdDryLzWA8XDBMFDeOFg+Ng7DMhqFYhihrBInhojy1UP4JR3
         s9JKBTlqQU1Ed19Uoj0X6Unix1BgjrC23ihFDYqCsw//dS0J8PW0QL1jyMbngEObEnso
         VI+2ab+PdTsq6Bshgkaevuz7zPbxPDTXAMyYFoczEskCCjWnXJxa9w2Hoy0aSeCgCRJf
         vA6+1b0T7DOwo8vqwsjaB3IVmaF4yDk7jpPTqTDQzkSwnUrv6qzbgozq1VdUCQM07j/1
         /jPw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=H2+x+MHVEZdCVE43yCMhl0CBsWPnqAGcA3mpEfmYBV4=;
        b=mhRqn9DLh/KPFFLk5YysaJC6kZJYHmSJDY4hnmm7A2JuwuwckAtMwPFzBYsoSoJEGZ
         j7Bqg5zoT+4oVmbzjvRKmqE0Kl70bN/h0kilIbfDwwVD5kHRrkXlTDv3P9vRh6n3EKw4
         S1KE/VnrTNz0T395Ez5cMkvPCoxjplhAel2REBZS4t6ttEwp6/nLfwG9PVbeCr8x0C6t
         yPWL7iihFNKJWgIWzP83DWvaA2W7REP+0cnsp0F0gQsmmvCoB7RecdlPy6puCudr1Rj6
         g86mp53q/tusFiDZm18Kvmxp0eMRxkjQBGdnpRHy2VvWhv8TxsHPJIp5lgW0gcDvgEVo
         g/Yw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=q4yLHaP0;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id z72si15631462pgz.56.2019.05.20.18.44.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 20 May 2019 18:44:55 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=q4yLHaP0;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=H2+x+MHVEZdCVE43yCMhl0CBsWPnqAGcA3mpEfmYBV4=; b=q4yLHaP0ptU37tRb4hLHZxJmm
	ew5v4etxyfhz8kN5laXZoOJo0kg4bdW+mbUnZQ4wTr6eX35KDhHy9W1FM/Th6gTkXw0m7JmwDncr6
	d3Ky/VrjxPss4IkozN7BQDI00Ja/RNMdxYF8ewPodxJQSznB04gOl3ramIHiqM4EMlydAhHLIowN+
	/LHHYx/EygTi582MDiFvUyClSpCqhAbjBrqUpmTy4G9UaWfAOAsVN8j7PkYrQd7fGlpm+UWv9ms8t
	XTjN+gKCo1BaWEOY1E123DatNsdFdKJYfobIgRpVoNrld/nW/6z2XcSSrfpaTTEqWOe7a2Gsbhf6i
	J1c0i7Rvg==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hStpl-0000XC-36; Tue, 21 May 2019 01:44:53 +0000
Date: Mon, 20 May 2019 18:44:52 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	Michal Hocko <mhocko@suse.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>
Subject: Re: [RFC 0/7] introduce memory hinting API for external process
Message-ID: <20190521014452.GA6738@bombadil.infradead.org>
References: <20190520035254.57579-1-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190520035254.57579-1-minchan@kernel.org>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 20, 2019 at 12:52:47PM +0900, Minchan Kim wrote:
> IMHO we should spell it out that this patchset complements MADV_WONTNEED
> and MADV_FREE by adding non-destructive ways to gain some free memory
> space. MADV_COLD is similar to MADV_WONTNEED in a way that it hints the
> kernel that memory region is not currently needed and should be reclaimed
> immediately; MADV_COOL is similar to MADV_FREE in a way that it hints the
> kernel that memory region is not currently needed and should be reclaimed
> when memory pressure rises.

Do we tear down page tables for these ranges?  That seems like a good
way of reclaiming potentially a substantial amount of memory.

