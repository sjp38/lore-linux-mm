Return-Path: <SRS0=iTus=TK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E87EBC04AB3
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 17:35:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9102A2182B
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 17:35:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="WnkWtS2C"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9102A2182B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EC9546B0003; Fri, 10 May 2019 13:35:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E791E6B0005; Fri, 10 May 2019 13:35:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D8F9B6B0006; Fri, 10 May 2019 13:35:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9F0D06B0003
	for <linux-mm@kvack.org>; Fri, 10 May 2019 13:35:32 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id o8so4498014pgq.5
        for <linux-mm@kvack.org>; Fri, 10 May 2019 10:35:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=H5lczeQR8T5im5nV/9sUhsnPFlc2c+myFo/mTa3LOKU=;
        b=Jv06o04SlEfaR7qZlCH8Ujgq6oQOhEeZwq2aBsyuSdvTPglsmAUA/phOaJj13uc39H
         Kq9z5R+XAQDlPhWY9k2nRNWm3tYY5p3c24K3jnwjmfZmN5FG6Jei7qCZmYXkfMqCEL2W
         0MUEcgbQ03hMHC2vFrs35SomeSeRzvoZRughm71ZRWJpaakwNwmiE7Bpnver6vvT9FPB
         phRqfR50SNIWtJzThtXYHH0B8tBFlrISabOYWu9Quc4y5uME8bXe3j0YvQjPEEqrsvAR
         yckfbvzERyGpou5k7yONTQ4lmbpbF3kOrlPZnRuuQzo2MxhqlusUEWGlaYN0wk6yfOJs
         NOOA==
X-Gm-Message-State: APjAAAWxVMqlEEb4v/weR4F87MzZ5u31EQNjGxwEAtOhnUjoOIQzP5uw
	2/H+5oIEbVxbf8bKo6dVIyie09s2vLN+zy5sR146eXbNOQA+eUQ985ExUGi7moNORGY5CB6Uvfb
	x8FhMWWTub1QJAzSM3MPVyR0RS7p/lxGbsT5bdHrqQuOhPCHTtnRUfmNt81wtur52Kg==
X-Received: by 2002:a63:f707:: with SMTP id x7mr15192176pgh.343.1557509732075;
        Fri, 10 May 2019 10:35:32 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy7uvbAfllt72+u7hUiqySrfzroFey0QA4eKGDTNRWUJJkcZsncJaCLNGOeQtKd4P0ZeRRf
X-Received: by 2002:a63:f707:: with SMTP id x7mr15192087pgh.343.1557509731313;
        Fri, 10 May 2019 10:35:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557509731; cv=none;
        d=google.com; s=arc-20160816;
        b=XQYBLzXmPLE1Pb9aLyYUvILIe9C4o3KMpRp//8L2XpFA5J6uMrxMipSRWRNZKV1dCK
         zSiO64R8nSylyay5ET5pv3veTcssNHagEzQemUUTdg22HnQN5iQufM5MOHjO1/PhZIhF
         QuJP9dnZYpsV02Tvz2e4+PPSmV5Dc3gQMOHpKuITSZZD12xSR893jI3VZ2voW/LDc43M
         y+ULEcfLielCKVEclpyLGXX64kdHp7YzwzJa0+kbatyQvDYQGt7gGNCqkV88bE4b/Bc1
         yOtYh/YWrOSyqWzjSTyGDzzwqnm6Rakz7cwIEVktw3R0qqGTIzOomMWPuuo7d/6vXg5S
         ubMw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=H5lczeQR8T5im5nV/9sUhsnPFlc2c+myFo/mTa3LOKU=;
        b=STRbj4VnSN+IyahfeNS0OJL8j1FuCddxDUvBNX/9UcfFDyTvjhh+4YCzsM6siY5so6
         814Xn1wFF0Rxb2pNmW7GnMi254gZ+y1wmIK0yxm+jjCyaM9QQT6jR6+YSTAGEice+V1o
         vHWBWk8aT78oSLFn/4+hRKY6j21tGRjKkTb6ijxEy4d3UjMQNojBhetcIv/gP8KhX70E
         1Naq6nfeXygeaatwp4ArOH1U8JjCo3IhvpIiyt6z/pQbmqSbCu5wTm+WRw0VkGmKIJea
         P5BkYwKMkFB2UevxFnVrUpcl8LRTMEw5svMbPbESqv2DpQnFcB8W7UZBCN6ApwyoWSnr
         8+fA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=WnkWtS2C;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id o188si8782059pgo.489.2019.05.10.10.35.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 10 May 2019 10:35:31 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=WnkWtS2C;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=H5lczeQR8T5im5nV/9sUhsnPFlc2c+myFo/mTa3LOKU=; b=WnkWtS2CsC+hpRDe5xAbSM/mG
	g4nTR835iYsDU702mbLsKjHu50iincTcRK28E2pRxEGbtloA2jSjanRQ83QXjjCAWxGwNJPFV1ZSH
	3RK89oHRcPwBKRcWMA58Xl0h+Ksjd2DMRR7DfESpEM8Cug9fdc90MHzOS/IJj5nnFuAEeflO82O3m
	EzZnbWaYauZ0lG+2g24WXNpMc+qm+b9VJO1siUOxh+WQF2IMdPsulQ6BNKwt1csNUlkm65Ahr0XYX
	3HXpFOIlUhKyig7/b+1qoDCoA2oKx29FmpVoUB7VDr60Bqutaqj7FJhhCs+cAwoiDA3GSupXNH0l4
	dZIIZql2A==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hP9Qf-0001w4-MO; Fri, 10 May 2019 17:35:29 +0000
Date: Fri, 10 May 2019 10:35:29 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: David Howells <dhowells@redhat.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Christoph Lameter <cl@linux.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-mm <linux-mm@kvack.org>
Subject: Re: Bulk kmalloc
Message-ID: <20190510173529.GA24921@bombadil.infradead.org>
References: <20190510135031.1e8908fd@carbon>
 <14647.1557415738@warthog.procyon.org.uk>
 <3261.1557505403@warthog.procyon.org.uk>
 <20190510165001.GA3162@bombadil.infradead.org>
 <20190510171110.GA3449@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190510171110.GA3449@infradead.org>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 10, 2019 at 10:11:10AM -0700, Christoph Hellwig wrote:
> On Fri, May 10, 2019 at 09:50:01AM -0700, Matthew Wilcox wrote:
> > kvmalloc() is the normal solution here.  Usual reasons for not being
> > able to do that would be that you do DMA to the memory or that you need
> > to be able to free each of these objects individually.
> 
> Note that you absolutely can do DMA to vmalloced buffers.  It just is
> very painful due to the manual coherency management..

... and we don't have proper APIs for it.  The last time we discussed
it was January, I think.

https://lore.kernel.org/patchwork/patch/1033921/

I haven't made any effort to try to come up with decent APIs for this.

