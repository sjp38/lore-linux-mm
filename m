Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B1521C282D9
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 20:00:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 768C320989
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 20:00:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 768C320989
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=deltatee.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 24B018E0004; Wed, 30 Jan 2019 15:00:19 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1FB3B8E0001; Wed, 30 Jan 2019 15:00:19 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 112D08E0004; Wed, 30 Jan 2019 15:00:19 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id DD78E8E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 15:00:18 -0500 (EST)
Received: by mail-it1-f198.google.com with SMTP id p124so101836itd.8
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 12:00:18 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding:subject;
        bh=Bv+EoAbZCx4b6A5Su91DoqrzFBf/2OFLuzI2khdqEPc=;
        b=a1WFrZd1dm0rPilQlU9bQb23kABbsVormSxc0OXEMDg069A/De1zA1YnH/lRCU5/Fi
         V9YCE4nGO2a9FfWIo2J+Kec36BUGLkETZJqFEsw5r3AXXguq58CPmIIrhQYL+U+9w/WO
         k7GfESc8hLUbJ//flo9WpBu3s2kb85iBhp7mRKORPsLZ7b/H5tq+sQvnO2greyZobo4H
         i+4VgiuMm0OO7mFV9JLQyOpQt6RCzb9R1pqw9r340P6pVZ6NecPZxCv71HTnxQYL1dxU
         PgisNvO9sR447wZVeCrxQe22eI2jAFS9nW8YAnkmq1X5uTmopHrUoVjpt4+HxtOF8xJR
         lKng==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) smtp.mailfrom=logang@deltatee.com
X-Gm-Message-State: AHQUAuaeA+TP1EYTuQ79xL3/41fsTsX1FFhnwtrkmJIkDz/OpyMSkvcf
	siWREQYehbK6gLLSUZMByUIdlZ/fWjYpxHaunIyCseoohXKNu9avJq2K5cPjOVwCAD64F47GQDu
	r7cZGK5cJlBsbCijNEs6sLEAky68gbyqfTd/6HY0AnkWVNjxjgLcpHLl2bEnc6NdHow==
X-Received: by 2002:a6b:c402:: with SMTP id y2mr20130801ioa.77.1548878418698;
        Wed, 30 Jan 2019 12:00:18 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7Pn8T/QeBwp1E9esHDW4an31/TqCq4ECEJEimFe4nu57DVI+em7TE+DsC0pisFiYCDpgvz
X-Received: by 2002:a6b:c402:: with SMTP id y2mr20130775ioa.77.1548878418158;
        Wed, 30 Jan 2019 12:00:18 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548878418; cv=none;
        d=google.com; s=arc-20160816;
        b=WOgvC8EaZnhVxc/UuzhfLs4jrzFLDdD02rDkbHDbP26IoTNvqrjTcR+w6aSP3EYhyF
         f+z8Bb8g0d9XdbxhFzTAp50KacNccfKQOuzs44pmfYLXWiMCfmdWdz1Aoo09ufCcxtwp
         QIRedhB80XUz7oA7EBZHY42iDuhdJHu0Yspm7iM2DBRMZFhph0NvrQuUQ0hJwYSbAly7
         cSwlbtEhMcUHw3kCskxV1KAqJVE475++wbdlAMjPbi7UXXDGqGH+zTjD8VRyLSDGm1Rq
         7ucSpdc0tioFGIs449OwWeR8trMBFPAvvf9PQ5dK1/QvnpGhNdT16UvXQi4n67QHyLfI
         ysbg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=subject:content-transfer-encoding:content-language:in-reply-to
         :mime-version:user-agent:date:message-id:from:references:cc:to;
        bh=Bv+EoAbZCx4b6A5Su91DoqrzFBf/2OFLuzI2khdqEPc=;
        b=jKyT90F8oYsg27y3cekPbcCXKBv3Ni5/Glp3oAnI9aNYWHsCDGeAGTeO7VT5Zmdcjt
         G4Mn7Rt5oomH12QDDazGhXxIt3MJ2eXTvlfvwsmlkH0fniDi8K6syJ8SC1jgIW75GQIW
         g+JoE9PcK13eWoN5znHx+msM8J+OS3PmPKwjc7GOXQL/WAICll57Zwr7eURiWcNMUo2H
         XCPkNyZ22kuw/99sH1tlG3g6g/K5s1d+7jJYG1ciou5lmkEE+vCZ/cJVATBPEK28vXlt
         0DF4t+j+IFnRoY3CQHWpKFTmzZ+/bB2OhqOgMOiq9mBCfqNO/uxwbadtElkk/cx4AhMu
         lmrA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) smtp.mailfrom=logang@deltatee.com
Received: from ale.deltatee.com (ale.deltatee.com. [207.54.116.67])
        by mx.google.com with ESMTPS id x9si1311776iob.138.2019.01.30.12.00.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 30 Jan 2019 12:00:18 -0800 (PST)
Received-SPF: pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) client-ip=207.54.116.67;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) smtp.mailfrom=logang@deltatee.com
Received: from s01061831bf6ec98c.cg.shawcable.net ([68.147.80.180] helo=[192.168.6.205])
	by ale.deltatee.com with esmtpsa (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128)
	(Exim 4.89)
	(envelope-from <logang@deltatee.com>)
	id 1gow1l-00005u-Hy; Wed, 30 Jan 2019 13:00:06 -0700
To: Jason Gunthorpe <jgg@mellanox.com>, Jerome Glisse <jglisse@redhat.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>,
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
References: <20190129205749.GN3176@redhat.com>
 <2b704e96-9c7c-3024-b87f-364b9ba22208@deltatee.com>
 <20190129215028.GQ3176@redhat.com>
 <deb7ba21-77f8-0513-2524-ee40a8ee35d5@deltatee.com>
 <20190129234752.GR3176@redhat.com>
 <655a335c-ab91-d1fc-1ed3-b5f0d37c6226@deltatee.com>
 <20190130041841.GB30598@mellanox.com>
 <bdf03cd5-f5b1-4b78-a40e-b24024ca8c9f@deltatee.com>
 <20190130185652.GB17080@mellanox.com> <20190130192234.GD5061@redhat.com>
 <20190130193759.GE17080@mellanox.com>
From: Logan Gunthorpe <logang@deltatee.com>
Message-ID: <db873687-ff80-4758-0b9f-973f27db5335@deltatee.com>
Date: Wed, 30 Jan 2019 13:00:02 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190130193759.GE17080@mellanox.com>
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



On 2019-01-30 12:38 p.m., Jason Gunthorpe wrote:
> On Wed, Jan 30, 2019 at 02:22:34PM -0500, Jerome Glisse wrote:
> 
>> For GPU it would not work, GPU might want to use main memory (because
>> it is running out of BAR space) it is a lot easier if the p2p_map
>> callback calls the right dma map function (for page or io) rather than
>> having to define some format that would pass down the information.
> 
> This is already sort of built into the sgl, you are supposed to use
> is_pci_p2pdma_page() and pci_p2pdma_map_sg() and somehow it is supposed
> to work out - but I think this is also fairly incomplete.


> ie the current APIs seem to assume the SGL is homogeneous :(

We never changed SGLs. We still use them to pass p2pdma pages, only we
need to be a bit careful where we send the entire SGL. I see no reason
why we can't continue to be careful once their in userspace if there's
something in GUP to deny them.

It would be nice to have heterogeneous SGLs and it is something we
should work toward but in practice they aren't really necessary at the
moment.

>>> Worry about optimizing away the struct page overhead later?
>>
>> Struct page do not fit well for GPU as the BAR address can be reprogram
>> to point to any page inside the device memory (think 256M BAR versus
>> 16GB device memory).
> 
> The struct page only points to the BAR - it is not related to the
> actual GPU memory in any way. The struct page is just an alternative
> way to specify the physical address of the BAR page.

That doesn't even necessarily need to be the case. For HMM, I
understand, struct pages may not point to any accessible memory and the
memory that backs it (or not) may change over the life time of it. So
they don't have to be strictly tied to BARs addresses. p2pdma pages are
strictly tied to BAR addresses though.

Logan

