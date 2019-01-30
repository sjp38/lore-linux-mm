Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 66865C282D9
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 17:17:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2A5DA218A3
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 17:17:51 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2A5DA218A3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=deltatee.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B55648E0002; Wed, 30 Jan 2019 12:17:50 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ADC718E0001; Wed, 30 Jan 2019 12:17:50 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 97E348E0002; Wed, 30 Jan 2019 12:17:50 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id 701A18E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 12:17:50 -0500 (EST)
Received: by mail-it1-f199.google.com with SMTP id w15so257097ita.1
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 09:17:50 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding:subject;
        bh=R/2KKZrF3cW4kpTnVrJ6er6dX3A+Ko+Vtna92VCp9Qs=;
        b=cTr7U2rApByUOUi/a5eYDAY1OjR+Pagz6odnzp7WkcJIA44INuqXfM6StwCxYlrmTS
         20nfAsoVr0Y83EkPJFULA2GZKV1w6Zf2Wwu7H9zQyGvzlnrL+xi6UIgshhD0sdUMeje/
         nSa7JEAA19FfLEL7aqLCandDzdH0X8zVeGsTYWi7gqJj2IQLX94dCkWK0yO615yCXAaf
         Mv1S/aGhzmli9aVyIHvss8EF3FohTS2hSbBSDxy10vXromCH9y8PyR8ow7xDayLOoC/H
         yGxX8NLjp7wPyX3ogVdkjg1zdoaC/naEhmG9dERroTkMmsi8Ehj6p7idhGaYO/2ipjJQ
         cvJw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) smtp.mailfrom=logang@deltatee.com
X-Gm-Message-State: AHQUAubWKPAyMtwT5a8bY5D7f56+LyFCfexPo/3E8ZCzer54xhdIlr1V
	zcz26fewBdph1CbE9n0HLlPpyyz1sOQ9pw11N+h+wz/g6BKRaU6GrL4Obgd42aD4S3rkX7EC4/d
	kVXOdO39nF3F77s4QOcwkX6SrKa/+PVURxqrnwfT2ZQw1UfFtRfQEmEVNlSLmhtdTxQ==
X-Received: by 2002:a5d:84c1:: with SMTP id z1mr17342883ior.277.1548868670241;
        Wed, 30 Jan 2019 09:17:50 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYRSLBEjARig781RuKy/jS2bwlhZ/kvA1zrceWBT7o/K9R5RpoyF4r8rY3IuDbjrq0eJ6G6
X-Received: by 2002:a5d:84c1:: with SMTP id z1mr17342850ior.277.1548868669524;
        Wed, 30 Jan 2019 09:17:49 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548868669; cv=none;
        d=google.com; s=arc-20160816;
        b=gGbcymSsTLh2Jk3vHCqjq31f2BWr/GMuzm2VCVePH56tSr2Obyffx7IRnZE3n9AUCA
         R/yWO2gEDejvUlOFdl0uplEiRUPfz6b3VsTjzfTpgxFs3V9T3v38KPKoMK1b7Sn5281C
         OShHnU4lUX/vTwxrChHYenQbruMdpuFYpz2H4VgTkl/KG3LzrrTUtXjw9GlnKjtS7OLI
         83IeIcgI9milhpEceHRHxfRvBkQSGT6HzQ4K9TS/TpvjctxyGXja4VStLKNrcy5naNf0
         dxv6ZEwVBgiHJe3V495ciHQyWNRpvWywIq3mjG6Ej+UQt+p0B4NwCjqCcWizTejQUzVT
         /ibQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=subject:content-transfer-encoding:content-language:in-reply-to
         :mime-version:user-agent:date:message-id:from:references:cc:to;
        bh=R/2KKZrF3cW4kpTnVrJ6er6dX3A+Ko+Vtna92VCp9Qs=;
        b=iIR9TXUconiAedmDNYp+1wgC2LLHN95TRabTjC+0R79jxz/Q9JpoDCAo7wX9XRK7iS
         PFTvlWUAEEICaKj9PuM/FzFtvVRxH0KOdi1mdgAC3cFrq7Pts7TEsMoABpHEIn31QAVW
         Z5Z35UnRtRYhhAWi5uTZoyw9BgRLM3zRXb8w6SibEWccJ+d6DJMEx7UhvUxBYCwsW/4A
         QgXe1U6ISQYW7qN0+5dQ/y8bl4iKID5Fh+UFklatbjAruqeJnk0l4OsZoI9nLnmy8BSy
         M1zUCFD68nHjG5TbFpnYDcpcvNElCIYL/tGlavaWSWWZzftxC5Ch3vxo7ZvlWoS869O8
         onOg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) smtp.mailfrom=logang@deltatee.com
Received: from ale.deltatee.com (ale.deltatee.com. [207.54.116.67])
        by mx.google.com with ESMTPS id n9si1431632itb.135.2019.01.30.09.17.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 30 Jan 2019 09:17:49 -0800 (PST)
Received-SPF: pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) client-ip=207.54.116.67;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) smtp.mailfrom=logang@deltatee.com
Received: from s01061831bf6ec98c.cg.shawcable.net ([68.147.80.180] helo=[192.168.6.205])
	by ale.deltatee.com with esmtpsa (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128)
	(Exim 4.89)
	(envelope-from <logang@deltatee.com>)
	id 1gotUV-0006Y7-9V; Wed, 30 Jan 2019 10:17:36 -0700
To: Jason Gunthorpe <jgg@mellanox.com>
Cc: Jerome Glisse <jglisse@redhat.com>,
 "linux-mm@kvack.org" <linux-mm@kvack.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 "Rafael J . Wysocki" <rafael@kernel.org>, Bjorn Helgaas
 <bhelgaas@google.com>, Christian Koenig <christian.koenig@amd.com>,
 Felix Kuehling <Felix.Kuehling@amd.com>,
 "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
 "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
 Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>,
 Robin Murphy <robin.murphy@arm.com>, Joerg Roedel <jroedel@suse.de>,
 "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>
References: <ae928aa5-a659-74d5-9734-15dfefafd3ea@deltatee.com>
 <20190129191120.GE3176@redhat.com> <20190129193250.GK10108@mellanox.com>
 <99c228c6-ef96-7594-cb43-78931966c75d@deltatee.com>
 <20190129205749.GN3176@redhat.com>
 <2b704e96-9c7c-3024-b87f-364b9ba22208@deltatee.com>
 <20190129215028.GQ3176@redhat.com>
 <deb7ba21-77f8-0513-2524-ee40a8ee35d5@deltatee.com>
 <20190129234752.GR3176@redhat.com>
 <655a335c-ab91-d1fc-1ed3-b5f0d37c6226@deltatee.com>
 <20190130041841.GB30598@mellanox.com>
From: Logan Gunthorpe <logang@deltatee.com>
Message-ID: <bdf03cd5-f5b1-4b78-a40e-b24024ca8c9f@deltatee.com>
Date: Wed, 30 Jan 2019 10:17:27 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190130041841.GB30598@mellanox.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-SA-Exim-Connect-IP: 68.147.80.180
X-SA-Exim-Rcpt-To: iommu@lists.linux-foundation.org, jroedel@suse.de, robin.murphy@arm.com, m.szyprowski@samsung.com, hch@lst.de, dri-devel@lists.freedesktop.org, linux-pci@vger.kernel.org, Felix.Kuehling@amd.com, christian.koenig@amd.com, bhelgaas@google.com, rafael@kernel.org, gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jglisse@redhat.com, jgg@mellanox.com
X-SA-Exim-Mail-From: logang@deltatee.com
Subject: Re: [RFC PATCH 3/5] mm/vma: add support for peer to peer to device
 vma
X-SA-Exim-Version: 4.2.1 (built Tue, 02 Aug 2016 21:08:31 +0000)
X-SA-Exim-Scanned: Yes (on ale.deltatee.com)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 2019-01-29 9:18 p.m., Jason Gunthorpe wrote:
> Every attempt to give BAR memory to struct page has run into major
> trouble, IMHO, so I like that this approach avoids that.
> 
> And if you don't have struct page then the only kernel object left to
> hang meta data off is the VMA itself.
> 
> It seems very similar to the existing P2P work between in-kernel
> consumers, just that VMA is now mediating a general user space driven
> discovery process instead of being hard wired into a driver.

But the kernel now has P2P bars backed by struct pages and it works
well. And that's what we are doing in-kernel. We even have a hacky
out-of-tree module which exposes these pages and it also works (but
would need Jerome's solution for denying those pages in GUP, etc). So
why do something completely different in userspace so they can't share
any of the DMA map infrastructure?

Logan

