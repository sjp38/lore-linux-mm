Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1F1E9C282C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 18:25:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CF69E222BB
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 18:25:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="YWnypiHl"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CF69E222BB
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6CB988E0005; Tue, 12 Feb 2019 13:25:14 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 651D58E0001; Tue, 12 Feb 2019 13:25:14 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4F42B8E0005; Tue, 12 Feb 2019 13:25:14 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 09E3B8E0001
	for <linux-mm@kvack.org>; Tue, 12 Feb 2019 13:25:14 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id n24so2640587pgm.17
        for <linux-mm@kvack.org>; Tue, 12 Feb 2019 10:25:14 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=RC4IZK1s9EybjfNR63lj/kHB1U+1eDtcZL5M7f7tt9U=;
        b=Lmiy+/nW7CZOP7eQiQRsv6CveWuDwIp9P/5S5Djx0sblZ4vT3lFcJrlHhqhYx3iiQk
         3u+DZA78dPie8h9nTj8a1SFDc7USovQG/1O6OkqiYX4ZFPExTI0hWrNtWF3twCbuQ331
         7kfwvVYirqPBA5eU2HgQFYejy/tVGPplm9QlF17w9BDQNGClx6VBMw9P0KcOdZxZg1NZ
         EHE4M0SB2U28N33TjrIo2XGeafyitIw24WPvubqVx87HqF210Ni3m1v/6MWcV+r9ZDCs
         Mc4rSWX6x0aw4HY70ZfwkSgL1jegTHwJrS4MZPAs/xIrxulsYCkotNQNaZ/xSgF1Oewi
         vbPQ==
X-Gm-Message-State: AHQUAuZhWEAItxWL4qm5CdSGh4uXCuW200EPJtFI4R18AAV95sXBO4TE
	24s5zl3a/nSHKq5h/91rYGpjMXIVp/zezSniFKQn/Z9hD/5tKa4Jd0ElsHbVnjAn5xffrNHL2hS
	iIdi0VJ3LGkZwOobmT+AhJgLIlaV4+zjmMwDUtO6WYLOc4Ff2iWTbVwjSaRgQdP1maw==
X-Received: by 2002:a63:fa58:: with SMTP id g24mr4739679pgk.390.1549995913746;
        Tue, 12 Feb 2019 10:25:13 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ia7MxfJylovh7ryN+rdgiWgRM3GeRcNFstbvg8Noig5pCHseowTAv0J1C+h6X/fDMIhhDt8
X-Received: by 2002:a63:fa58:: with SMTP id g24mr4739651pgk.390.1549995913129;
        Tue, 12 Feb 2019 10:25:13 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549995913; cv=none;
        d=google.com; s=arc-20160816;
        b=KjHzuHR+Dd7ZTXFr1QLcEMPSrvAxbyL19JUKmxg435PTaiQf+quqdYm4jYqKBi34s6
         mib9fp0cELy4FHVna8eGTTfjSkthJkCWCrpPXmQw4Hdf6VGyAgdtp6EjG2LWZLM+3BIs
         VoVo9tzYbfIjxy+fN0X8mFpI8mQACSFA8WaOYy9/Ku2L5FglQ/VvhcT78hQvuEjHJuAE
         Pn4aOtuFGwtac4j2mecrUFTjrtnzIXpXGDKaNAw9YLFSJyGdm9fXjGhAAR9fqnzGYZvm
         dEUbVQfnKD96lushweG8JKynnp0PvEcGKhwStXmma4TZpunVEDqlNRspflx5lYxbvk6h
         +xXg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=RC4IZK1s9EybjfNR63lj/kHB1U+1eDtcZL5M7f7tt9U=;
        b=G7OhOXzRHkSJuNczKUPFYdReAb6/kLkW8s5oM0j/r0bFFjzLSFJKvGiud26ZBi6bvj
         lFi5DFT4x71iZRYfZNtaitBX1XseHjQsBN+9PfJOp7+7XB7XFMcEsB2IcsDRyJfdRY0c
         0nbT19uKdKRIex9Yr99dUWeMmBnQD8ezTdVgTyZ+TftD+rdpJxxMn72bZab5oxmHK3Sn
         bVSmp/eIEkUeiQ4EMrZsewTmfvpwpFIVTdO06CvfCPZ9sIQ8v/w2JvW+3yajCfk5URkw
         5REFrGAwpKGNAKrtMKuX0M5XTDBk1Ol46hCQ33N7aChO5VTWIE/BrHuHKHgw3JwpxDYi
         2MdQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=YWnypiHl;
       spf=pass (google.com: best guess record for domain of batv+2b38dff59ae25ce7f5e0+5651+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+2b38dff59ae25ce7f5e0+5651+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id h7si11285055pgp.49.2019.02.12.10.25.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 12 Feb 2019 10:25:12 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of batv+2b38dff59ae25ce7f5e0+5651+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=YWnypiHl;
       spf=pass (google.com: best guess record for domain of batv+2b38dff59ae25ce7f5e0+5651+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+2b38dff59ae25ce7f5e0+5651+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Transfer-Encoding
	:Content-Type:MIME-Version:References:Message-ID:Subject:Cc:To:From:Date:
	Sender:Reply-To:Content-ID:Content-Description:Resent-Date:Resent-From:
	Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=RC4IZK1s9EybjfNR63lj/kHB1U+1eDtcZL5M7f7tt9U=; b=YWnypiHlj/XDLEapHHo/9Hc5Vd
	4BIUFJlVExKIp3lwYX83Qx4CH8FZ3QM/xwZb8C2nR3bnkV4jsaXRIIbuvMGI4tUzh6TSytXz4LtHw
	zO8VuqZIxe5S2xspkL8i58E7d+hwwypTcHsxtt5eIcoCLE6W59J4ECXZxYJcnu9QiUx7cehiT4UE5
	S18ZggBl2ZbRzgyCqqLt3VCORQPIR3BeeQvY+4S+PNJzd+rI+yof3D/7iTmk4LUr9Zt4Bz/qjTXrb
	grbwSvQ2cMR2bdrcS83pOkpQo6Vqu/hnVHkODMywIXublCFAugXxciwxFIVTsbulwTfhnqaDioLw/
	muSXZUWg==;
Received: from hch by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gtck3-0004M7-MB; Tue, 12 Feb 2019 18:25:11 +0000
Date: Tue, 12 Feb 2019 10:25:11 -0800
From: Christoph Hellwig <hch@infradead.org>
To: =?iso-8859-1?Q?Ga=EBl?= PORTAY <gael.portay@collabora.com>
Cc: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org,
	Gabriel Krisman Bertazi <krisman@collabora.com>,
	kernel@collabora.com, Laura Abbott <labbott@redhat.com>,
	Mike Kravetz <mike.kravetz@oracle.com>
Subject: Re: [PATCH] ARM: dma-mapping: prevent writeback deadlock in CMA
 allocator
Message-ID: <20190212182511.GA10532@infradead.org>
References: <20190212042458.31856-1-gael.portay@collabora.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190212042458.31856-1-gael.portay@collabora.com>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 11, 2019 at 11:24:58PM -0500, Gaël PORTAY wrote:
> The ARM DMA layer checks for allow blocking flag (__GFP_DIRECT_RECLAIM)
> to decide whether to go for CMA or not. That test is not sufficient to
> cover the case of writeback (GFP_NOIO).

The ARM DMA layer doesn't, the CMA helper does.

> -	bool allowblock, cma;
> +	bool allowblock, allowwriteback, cma;
>  	struct arm_dma_buffer *buf;
>  	struct arm_dma_alloc_args args = {
>  		.dev = dev,
> @@ -769,7 +769,8 @@ static void *__dma_alloc(struct device *dev, size_t size, dma_addr_t *handle,
>  
>  	*handle = DMA_MAPPING_ERROR;
>  	allowblock = gfpflags_allow_blocking(gfp);
> -	cma = allowblock ? dev_get_cma_area(dev) : false;
> +	allowwriteback = gfpflags_allow_writeback(gfp);
> +	cma = (allowblock && !allowwriteback) ? dev_get_cma_area(dev) : false;

But this only fixes ARM, but not all the user callers of
gfpflags_allow_blocking and dma_alloc_from_contiguous.

I think we just need a dma_can_alloc_from_contigous helper and
switch all callers of dma_alloc_from_contiguous to it.

