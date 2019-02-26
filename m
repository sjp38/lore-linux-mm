Return-Path: <SRS0=HICI=RB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 40B23C43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 14:29:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F142020863
	for <linux-mm@archiver.kernel.org>; Tue, 26 Feb 2019 14:29:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="EOrWHMUq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F142020863
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 833A68E0003; Tue, 26 Feb 2019 09:29:45 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7E2868E0001; Tue, 26 Feb 2019 09:29:45 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6F9168E0003; Tue, 26 Feb 2019 09:29:45 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 290B88E0001
	for <linux-mm@kvack.org>; Tue, 26 Feb 2019 09:29:45 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id g197so10603619pfb.15
        for <linux-mm@kvack.org>; Tue, 26 Feb 2019 06:29:45 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=CukDaErtMT3ikoFe8SH8nKAbqlqTD7bFhtP2OfeZy5Y=;
        b=KpJlrlolFEei7/7IAelsYR+uFKeqOJ/IRmcdWiXHXfzEtimJJLD4zuizgY5bLjRfty
         Npf0JdJZVJj/OQ3FbFgW1fzlNxpZ0CUIV2HVj1erIXUsdhIYUFlWMIuLbkecRG1YbMo8
         W7ymqqxzk74owRanwhlB/BkTmxfU2rM9Cqj6XXByFh/2gdXg4IBV6aHUyWw19f2sYNEn
         H5KCjaXADyrgDob2f+wwAjuy0aDLYqEHmUIb3JWaRFfq3I2h3JCEhG8SXXoQs62d9m4q
         gVq4M718vV3Y3TaPo0MpvCNpeQwUtdbZy8g+uLn1a8sx/XcqgJXrZoqApilENpVleys7
         XUuA==
X-Gm-Message-State: AHQUAubBF0rloP2D9r8Tl11p5UXVBwyz2AX4TYSHeCHB19fgQo1nFC+C
	Vzp4MBUOp6gVFgDZdzoEiIM1xvwfJDorsxf028zv50dqSg0uI+AeDu6OJ7jPhAyzV+Ee7GGDlNp
	668by1OwT/wt+kJxWRdYfANKHwY5CGADXPznMQP4NFff9PNFy8nUP7raeXYYkMGobtw==
X-Received: by 2002:a62:be0b:: with SMTP id l11mr26809459pff.52.1551191384631;
        Tue, 26 Feb 2019 06:29:44 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbNfs6WHnOBTjRd+pzr6ANNkxfvhAjllNlSVs4w6kNbzjkBzDVOJEs350yRgLG1Obbw042K
X-Received: by 2002:a62:be0b:: with SMTP id l11mr26809400pff.52.1551191383675;
        Tue, 26 Feb 2019 06:29:43 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551191383; cv=none;
        d=google.com; s=arc-20160816;
        b=fRk7wBhB5jqmnbgmI1jLrxnsxlw0VsladTogiFo5facXfHplCpjECl9/zGu+luvjWl
         uY4YAN+rNhgDVqwLO9jU6W2BHTCTxjwlyaeOeIRbf7nAcHi6DJCst6V7ZnHbRnBTQ+qZ
         EPz+FetEq1yT3aFGoghrGnVM17OiCeu9KlNt7p/v0/9YCRGBVWrabANZGsgKRP7VBbOI
         D6xiUvUdC7N0EnaWK2Pel+QAgNyvpwdJ0ji4Q3nQGc+jP5+xwTeQFpPXuIvQDrjiaaR3
         L40/nk6kYhQKBwf8cnmckWpjr9qAsF3EnRMYs/6TzHVVwN+UdXRPgubPyW3wZUkHuI5k
         2DMw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=CukDaErtMT3ikoFe8SH8nKAbqlqTD7bFhtP2OfeZy5Y=;
        b=to8Vk/W2D6629bptRZZEKJJvh0rQSa1hPrwFLaqt0//2jwpLGzarPvPM/3iTMMHW8I
         a/BH/8+nu8LtIKTYFSgggXZ30iXeqbJ4m+O848OV5Mc5G6jRYYFstQJU4cgVB0P4UtCp
         ihjwlzZEFvWLoViWNacuvjUQvuSPllZpRmr7joLWc7Jeyu8pDUPgHWaoViJsBM6yLC1I
         50GTyicyxf6OwJk/jSYHmhw4XDuIo94zp5OWZuuQ90aykV9GOA0xCQdqMwGtQxno+Hv8
         bVioz7v5Nvi1biKkR1iJNxkz6dXjh7yABU4Vrxvk52qqYG2dsO8oi1Z+0eDl6V6XkkcO
         S5PQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=EOrWHMUq;
       spf=pass (google.com: best guess record for domain of batv+8115932e98e9c93b5750+5665+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+8115932e98e9c93b5750+5665+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id g3si11853825pgq.61.2019.02.26.06.29.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 26 Feb 2019 06:29:42 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of batv+8115932e98e9c93b5750+5665+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=EOrWHMUq;
       spf=pass (google.com: best guess record for domain of batv+8115932e98e9c93b5750+5665+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+8115932e98e9c93b5750+5665+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=CukDaErtMT3ikoFe8SH8nKAbqlqTD7bFhtP2OfeZy5Y=; b=EOrWHMUqtP0ikAezL07GksK/z
	uhJsfyQ/I7noAxqyEJCtwMtHojouj/a5xYxxapv0v16KZ9KZWH6kqVfxRSNuSJyzo/MrwYLQb/H5a
	Ia+9jJjPx/y07Zv+3bW18J2s+w0Crl17iyBYuWI0ujqtSN4erGLTSm666kINEgvBaKYdf2Wo2fY/f
	WfNbgaozOX/GeX+5FKR0NaiUkj4GzT8xeditPVzSsJnSkhb+FBa2sAUTqq00fSLymZKdtAQHE8Dwa
	XGnvLnvbUvqXetgFyxc6JMQmNGB06MYUpsdga5XGdtvnIjRf/eA6KWzNKQKcIYUfmUpXFf1+/gUkf
	4TZp9Q8Jg==;
Received: from hch by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gydjp-0004PI-Q5; Tue, 26 Feb 2019 14:29:41 +0000
Date: Tue, 26 Feb 2019 06:29:41 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Gabriel Krisman Bertazi <krisman@collabora.com>
Cc: linux-mm@kvack.org, labbott@redhat.com, kernel@collabora.com,
	gael.portay@collabora.com, mike.kravetz@oracle.com,
	m.szyprowski@samsung.com
Subject: Re: [PATCH 0/6] Improve handling of GFP flags in the CMA allocator
Message-ID: <20190226142941.GA13684@infradead.org>
References: <20190218210715.1066-1-krisman@collabora.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190218210715.1066-1-krisman@collabora.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

I don't think this is a good idea.  The whole concept of just passing
random GFP_ flags to dma_alloc_attrs / dma_alloc_coherent can't work,
given that on many architectures we need to set up new page tables
to remap the allocated memory, and we can't use arbitrary gfp flags
for pte allocations.

So instead of trying to pass them further down again we need to instead
work to fix all callers of dma_alloc_attrs / dma_alloc_coherent
that don't just pass GFP_KERNEL.

