Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A54AFC43613
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 10:51:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 711022070B
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 10:51:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 711022070B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0037F8E0007; Thu, 20 Jun 2019 06:51:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ECEE08E0002; Thu, 20 Jun 2019 06:51:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DE49A8E0007; Thu, 20 Jun 2019 06:51:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id 96B1F8E0002
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 06:51:55 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id e8so1016544wrw.15
        for <linux-mm@kvack.org>; Thu, 20 Jun 2019 03:51:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=BEEpkMXWvj7oR+wfAkuOS4waCs4VBdR1wOtlhK8+NmQ=;
        b=tOnImgj/yZoo1flSKOo2R5dncL+LwVstSsbnHXQHkfCNNE863tqRVcKlaIev/zmfGe
         iApP4WOGtO2ufsBjfIpdTfcscOpkzBuB1hXgUz8E5QZlXhDpqgjSj1YdPzjSo0Tvb5YB
         7Ym6c4Kst0YjA8X2kwwVkJsg5/KUAo0hQDW0g9QWIL7IhpBg/I34RnGL86berAQFIXYl
         mx1SkCTc9gSXuyr5wvML4m790j2rXBObQW6j6JMjSDUOpbojCgNBzRWEjCvHzJG1N02P
         YNASMeWIt5YTUW84N7jWxuRH6w4m2pWG+33lduqzTep8jD+PzCV3S8KLaPadzJsqF/nm
         qJ+g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAUZnOsSsNjaMIOkGbkCFmqTl1IDqRIq4hivGJC/HWlgjXtwdim5
	Lo1fLkfZ5l3CJ4VrfIDPsxu4W900wTcQJU/cCK4WEbu8V45sg75Xuj7cSluB137TWwI84GZ0RZI
	tQyvQ1n0cwLl0xeCO8ALq/yj5aTwSq8hiBitPM3p9jsKDzc17WIjqIYXs/WrfbspXPQ==
X-Received: by 2002:a1c:9d48:: with SMTP id g69mr2522103wme.31.1561027915096;
        Thu, 20 Jun 2019 03:51:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwuJ5he2LoUGCXYS25y6jyj8M1Frt0sKqMbd3ZFg1EcQ4fXLZjsuTPKK8E2Zaac4fOuR/fu
X-Received: by 2002:a1c:9d48:: with SMTP id g69mr2522056wme.31.1561027914434;
        Thu, 20 Jun 2019 03:51:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561027914; cv=none;
        d=google.com; s=arc-20160816;
        b=aS0USzgyJWd/KyI+L5vRMzXH1QH/RPq+m0b0wRh4c/+P06S8AZzyY7m/b+oEB2cBtA
         BCw2NvLJzvjdqrVkBQXYyTWgSevrDtJ/w/UELakIT99iUPZjI1vpDx++jULB+WNwlwW6
         Axe50MBa+9ZsscxjuwmgFfeAoZjaqbQlJZjBiUVHxzbPfhGPZwZ7Td9I/6CMAewxFTTI
         c/JgtA+/D1PQ3/Y3IgYjAmulex2jdS80d71dnxTdiDApMm65fuXEFebfifzMfawSVr6i
         W5duHREC665ynB62/A1XWsnLv5dVvEW+/a2oKKdnsX79U4txAO41QgaTS99jccchT4qN
         Vi/g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=BEEpkMXWvj7oR+wfAkuOS4waCs4VBdR1wOtlhK8+NmQ=;
        b=ojiEigcMyrbDDvELxh6acwrAdn5Qcpm02cyoTQLZlJEnjNnebW1AzqKVUJUnfdGZoG
         TvsbJ3vpXdeGMo2cMtLRiP/7CqHuJ4zGTZK36pct6lYk4yys7XL098fKEPYME1AZBTjd
         NUKI5EbTgJY3YLPAuCW/1t8R0BVlsbQ1RDxhhXWVjaQZ/r7d3OJ2uyCHyZ1Lg+i2nen5
         FpHxEtuOVpBFo2NizdvjtoxvNFckVG8CtQwbf7o86yHfofv+RAb38ZPiNmGWFI7bHqQG
         qwOcd3pb62TVe+2W3RkpkNj4VGtT2RSDQV4hOQwmqHIDldfH3/IoKfVEg+BX52jSS9Af
         aX2Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id s2si17543953wru.119.2019.06.20.03.51.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jun 2019 03:51:54 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id 558CF68B20; Thu, 20 Jun 2019 12:51:24 +0200 (CEST)
Date: Thu, 20 Jun 2019 12:51:24 +0200
From: Christoph Hellwig <hch@lst.de>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Christoph Hellwig <hch@lst.de>,
	Potnuri Bharat Teja <bharat@chelsio.com>,
	Dan Carpenter <dan.carpenter@oracle.com>,
	Maarten Lankhorst <maarten.lankhorst@linux.intel.com>,
	Maxime Ripard <maxime.ripard@bootlin.com>,
	Sean Paul <sean@poorly.run>, David Airlie <airlied@linux.ie>,
	Daniel Vetter <daniel@ffwll.ch>,
	Jani Nikula <jani.nikula@linux.intel.com>,
	Joonas Lahtinen <joonas.lahtinen@linux.intel.com>,
	Rodrigo Vivi <rodrigo.vivi@intel.com>,
	Ian Abbott <abbotti@mev.co.uk>,
	H Hartley Sweeten <hsweeten@visionengravers.com>,
	devel@driverdev.osuosl.org, linux-s390@vger.kernel.org,
	Intel Linux Wireless <linuxwifi@intel.com>,
	linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
	intel-gfx@lists.freedesktop.org, linux-wireless@vger.kernel.org,
	linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org,
	linux-mm@kvack.org, iommu@lists.linux-foundation.org,
	"moderated list:ARM PORT" <linux-arm-kernel@lists.infradead.org>,
	linux-media@vger.kernel.org
Subject: Re: use exact allocation for dma coherent memory
Message-ID: <20190620105124.GA25233@lst.de>
References: <20190614134726.3827-1-hch@lst.de> <20190617082148.GF28859@kadam> <20190617083342.GA7883@lst.de> <20190619162903.GF9360@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190619162903.GF9360@ziepe.ca>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 19, 2019 at 01:29:03PM -0300, Jason Gunthorpe wrote:
> > Yes.  This will blow up badly on many platforms, as sq->queue
> > might be vmapped, ioremapped, come from a pool without page backing.
> 
> Gah, this addr gets fed into io_remap_pfn_range/remap_pfn_range too..
> 
> Potnuri, you should fix this.. 
> 
> You probably need to use dma_mmap_from_dev_coherent() in the mmap ?

The function to use is dma_mmap_coherent, dma_mmap_from_dev_coherent is
just an internal helper.

That beiŋ said the drivers/infiniband code has a lot of
*remap_pfn_range, and a lot of them look like they might be for
DMA memory.

