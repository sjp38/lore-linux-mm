Return-Path: <SRS0=QIji=SN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3C403C10F14
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 13:28:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AED36217F4
	for <linux-mm@archiver.kernel.org>; Thu, 11 Apr 2019 13:28:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="VuRmDIon"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AED36217F4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 120A46B0008; Thu, 11 Apr 2019 09:28:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0D2826B000C; Thu, 11 Apr 2019 09:28:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F2AEE6B000D; Thu, 11 Apr 2019 09:28:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id B78046B0008
	for <linux-mm@kvack.org>; Thu, 11 Apr 2019 09:28:23 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id l74so4226213pfb.23
        for <linux-mm@kvack.org>; Thu, 11 Apr 2019 06:28:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=6VFuhNCf+gH+llXbEHsi41/TZwlA6SKkFNV6Ppyi0Os=;
        b=HNiBI0Qu0dcHbeXWOEoyfObZruGsJJ/9jig5JLTKNONbOZobDoO0X+mAGfGKaUvxdv
         SiYcqoBF1cHccm6dIFtK5D5BzRqfy2XVUHczW3Gt83BmjBdq/Gl/FzJkkAa29Y2/bj36
         t9jXY4GC6Wp85TgCI6xMw9c7UoLnfVJ/agcEnAcLAfbgypPztsamj6gN47o5ae7nCXWz
         yPtUjycJ14Cro+l+SfIkbssR/AfXYlKayXzAZ0Gy6hPsfaOo9HvbyS9Go6Epd8zEOv1p
         LprcWPwrxFE8S8blYCAIqPh9z7aEtuipO8BRLkxgPhRJI7sqjvWO1wd5H9OyMvnv7/Aj
         3FeQ==
X-Gm-Message-State: APjAAAVnNzm4SdScIe6QAiFlFzGbF2oSBXRdFH3eqR0V8SDyBSEio36D
	wj/5kCB650GNRxUCYDBMoyL1VURNNQfPubxuRwNztj8zHw9W18H/sOJg83drbr4vf959yHkWS43
	1JZsGHR8uuMxyGasni/etJ1LSn3BuKMMgs2NpSpr8YdyxJjseY7WFRjQ2HbPsArw9Cw==
X-Received: by 2002:a63:360e:: with SMTP id d14mr46387996pga.188.1554989303292;
        Thu, 11 Apr 2019 06:28:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx7wpSC57vovjj0sG/dO4CqgvpsB73DBS316bVTSm8lqjEhXU4lXt/a16o+84xToodikdJ4
X-Received: by 2002:a63:360e:: with SMTP id d14mr46387932pga.188.1554989302502;
        Thu, 11 Apr 2019 06:28:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554989302; cv=none;
        d=google.com; s=arc-20160816;
        b=Mbabi4+e+s7jdQ6yt/EwChH3lXNRj7bq3CevBdE0P79sKOX93QBRRKyK2nluXiNKnP
         1Id4C9FhNmCO1gC/GNGAlazNbe3yWpso6MJrnFE0RdEJsmr+Ab1LX850v6m1V6lopqzb
         CaIkXbmNfU8jadaq3jvmfvVRodmJdh7NXyfBEJxPdvi6SfrvyMSgNCTfSIbVEtCBi+Je
         QR7W4gvRvTplTj80k3S6iF0a951BqUTPxYy5Su0ed6fGWeRLTIxyEt14EtoJpej/Ffg+
         QxbmYfdbOPkWMeFQbpfXTxTA6qEoygu80giAQFR8SuoLBs/bnZ44yLp69eBcolih1C8w
         0GVw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=6VFuhNCf+gH+llXbEHsi41/TZwlA6SKkFNV6Ppyi0Os=;
        b=mmXbMLDqTAQGn6XWzCLx4Ds9jgJFspW8SyLHXiU1yTeXOqBkwcRt35ZLvlvg7Ytt+4
         U8yqBHh4IsJeLShXh04+Fmp5vOcETZWeCmf+uiOPPmG1rzO0v7MIteXRMaEStl5Wf4xC
         wRiCAWBYLMdzhb9kxDYmDotSsrYgK/F6T9YSDS1xLWN+Yrkz0KWJk9YgYx8c9CU6R8vG
         Y6QPmcdKbFEUaKOJ6+SCflxhpVPTJMx0vQ8MYKoW/PLIkr+uP3+Rl/MTBxB+R1IhCRah
         xdeWguRBiZMEWEt7tR25d4jKNZ7zyC99Gj4S5gJah9BG6ybrY18YWsrLdyxKJXckBxH5
         FGKA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=VuRmDIon;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id b128si3758436pfb.141.2019.04.11.06.28.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 11 Apr 2019 06:28:22 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=VuRmDIon;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=6VFuhNCf+gH+llXbEHsi41/TZwlA6SKkFNV6Ppyi0Os=; b=VuRmDIoncI2k8GTzl20u00d+I
	eBhCx9kBdWBraFVeGej9WAi4QaDRhmbyH/CzYXmIptJtzET/2Ef9e5tiQjpr+gNDEyvF6o6rA6a+B
	L1PNZQuCwUsgEDdCXc0zlu/agnCQZcjLOhjgWiQyijKVVlVUqAQ5hDpJ9uHAy0ZuX7KUNhSWP1WA8
	wmoiN/M18X7Xv831vE/Mllly0QDoMn+hoOHwmNFn4CdifhpWJ+GJxr0IBUOdFdRJo1fR+sIJ4pSvL
	SvAfzuuSCLahhHVKDCR5q2suIN4ZfSpC0ze5sJTxpbt/wT3b5E0+b+TThbtMOLxMq8a/PJA4vqv7y
	yYvVTtgsA==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hEZkZ-0007O7-Cw; Thu, 11 Apr 2019 13:28:19 +0000
Date: Thu, 11 Apr 2019 06:28:19 -0700
From: Matthew Wilcox <willy@infradead.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: lsf-pc@lists.linux-foundation.org,
	Linux-FSDevel <linux-fsdevel@vger.kernel.org>,
	linux-mm <linux-mm@kvack.org>, linux-block@vger.kernel.org,
	Michal Hocko <mhocko@kernel.org>, Christoph Lameter <cl@linux.com>,
	David Rientjes <rientjes@google.com>,
	Pekka Enberg <penberg@kernel.org>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Ming Lei <ming.lei@redhat.com>, linux-xfs@vger.kernel.org,
	Christoph Hellwig <hch@infradead.org>,
	Dave Chinner <david@fromorbit.com>,
	"Darrick J . Wong" <darrick.wong@oracle.com>
Subject: Re: [LSF/MM TOPIC] guarantee natural alignment for kmalloc()?
Message-ID: <20190411132819.GB22763@bombadil.infradead.org>
References: <790b68b7-3689-0ff6-08ae-936728bc6458@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <790b68b7-3689-0ff6-08ae-936728bc6458@suse.cz>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 11, 2019 at 02:52:08PM +0200, Vlastimil Babka wrote:
> In the session I hope to resolve the question whether this is indeed the
> right thing to do for all kmalloc() users, without an explicit alignment
> requests, and if it's worth the potentially worse
> performance/fragmentation it would impose on a hypothetical new slab
> implementation for which it wouldn't be optimal to split power-of-two
> sized pages into power-of-two-sized objects (or whether there are any
> other downsides).

I think this is exactly the kind of discussion that LSFMM is for!  It's
really a whole-system question; is Linux better-off having the flexibility
for allocators to return non-power-of-two aligned memory, or allowing
consumers of the kmalloc API to assume that "sufficiently large" memory
is naturally aligned.

Another possibility that should be considered is introducing a kmalloc()
variant like posix_memalign() that allows for specifying the alignment,
or just kmalloc_naturally_aligned().

And we probably need to reiterate for the benefit of those not following
the discussion that creating a slab cache (which does allow for alignment
to be specified) is impractical for this use case because the actual
allocations are of variable size, but always need to be 512-byte aligned.

