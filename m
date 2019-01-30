Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 03B30C282D9
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 19:46:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C34D92184D
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 19:46:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C34D92184D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=deltatee.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 565EF8E0018; Wed, 30 Jan 2019 14:46:05 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4ED598E0001; Wed, 30 Jan 2019 14:46:05 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 38E248E0018; Wed, 30 Jan 2019 14:46:05 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0F88B8E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 14:46:05 -0500 (EST)
Received: by mail-it1-f197.google.com with SMTP id 135so76584itb.6
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 11:46:05 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding:subject;
        bh=fpZGsSzil/iXoEwQkvIs5BnVmUKnDpCsYxqfz253Eac=;
        b=uTvq9J4IrUbqWekzF/OzuYcsYT0Aot0o62aGJo6I2kFRYQw6z3nfvezDpCWf1cP51E
         0a917nCUCm44rXs2JjKYhiz+y4elHJJAXDhbDASluhDzJb0ua8nA5fkaQJEHw2clZ8IX
         q9DqCxB1ovspsi4XzRL94FvRJhOSioL1Wm0WM2BQKFsgh6q02R5w9IEsX//yEtDlvo+N
         7e19Ebgjc+mgMtzD6e2mUCAeqrmHaoU5DVNzPIZQepVB/uKjnmyrI8LkzOqrDAuGvGga
         /7YoQNLHFNPsp+lq1Adak7zpvgJE0iyPLOyjZ5p9QGScCWsa4EKiTpE/qG/SPzns+Xrk
         Namw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) smtp.mailfrom=logang@deltatee.com
X-Gm-Message-State: AHQUAuajT9UgCOPPn2zTjNzEJY8Tq7FIDAEIeRtGCaWKMaEUU30f2BPU
	DVQ8arPzYUQAMa6LcjvrrSVdrR9IDmAFKyKLt3N9MRCMcKCEZOAREsmWlYt3pTY9P18h+bSA6Mw
	x4y/H6OKGqGBbbTWTMzAwldzIyzX5xCxUhvj9O2+fn74kzTjrtoDDX1qd58SDzTndFQ==
X-Received: by 2002:a24:874a:: with SMTP id f71mr1428051ite.120.1548877564775;
        Wed, 30 Jan 2019 11:46:04 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZPz0EoMLyBPoSV9sS1fu+M2CBolWty5yTnBra4R6tAlSL23dutyEGhVMdRDu/2XzgBTsWn
X-Received: by 2002:a24:874a:: with SMTP id f71mr1428034ite.120.1548877564181;
        Wed, 30 Jan 2019 11:46:04 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548877564; cv=none;
        d=google.com; s=arc-20160816;
        b=Uw8zqF8LzHB0H7PH3GWX3UMeEPq5MGKDoKAqyLUwmZfsVZMnDkUoFcPgleFXWiArhS
         J0eynjyxiuwELKuiADrF2qpaATrzv2B9C+RrVVmzObUKaYXGZUsPaGYdAL6sJAOiGhTa
         gQOeQjJ37O4qD3zb9s0oRy+uwsq9Euumo5HfWfFHcncoel+FKW3QZElWNmphaz6/jqG3
         z+2+CFArGD+gvtwxztYlSbPFhXTdLx+7fnHOvzsW5/yid4nWCW2M9omAEA15NDwMV2sX
         eccKCVB+gWlsaGBIuTo9kkdeZ+MEoh14ZauaaiN7vCF81HQLjUA4r/TlRxfl28ZosuR+
         2UpA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=subject:content-transfer-encoding:content-language:in-reply-to
         :mime-version:user-agent:date:message-id:from:references:cc:to;
        bh=fpZGsSzil/iXoEwQkvIs5BnVmUKnDpCsYxqfz253Eac=;
        b=lNnPP23Y1aoTTsTFPeJ0GR6bSRij637ULQ8ecZbsqGUAOFQWrvG64au2l4H5t4CixQ
         xSKECuh7bhPAimbVgSzCIA//noxZ6xHBt1MjO5CirZApmyo3yNfPpENf47BR/+14fWoi
         oDP/0I56LVFM72hlngZAt3mTrisg4jwbphqY74zhmi/9RKr25TMEQKX+NIkjLm+O54bG
         fuTVkm6Qo8APwPkZ/CP9/7ZpD6EkbMEKj85dtUUZkhir+3IjIYVF4BTxvjIQV3BQtUnv
         KOtHZ0wQIWlotRl2ePQ4FW+ft4KYIweCbnfJMP6zDp6dCPnAMb3BSw/LvG5D+pHh0G3n
         iS9A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) smtp.mailfrom=logang@deltatee.com
Received: from ale.deltatee.com (ale.deltatee.com. [207.54.116.67])
        by mx.google.com with ESMTPS id t4si1566179itj.95.2019.01.30.11.46.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 30 Jan 2019 11:46:04 -0800 (PST)
Received-SPF: pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) client-ip=207.54.116.67;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) smtp.mailfrom=logang@deltatee.com
Received: from s01061831bf6ec98c.cg.shawcable.net ([68.147.80.180] helo=[192.168.6.205])
	by ale.deltatee.com with esmtpsa (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128)
	(Exim 4.89)
	(envelope-from <logang@deltatee.com>)
	id 1govny-0008PD-5M; Wed, 30 Jan 2019 12:45:51 -0700
To: Jason Gunthorpe <jgg@mellanox.com>, Christoph Hellwig <hch@lst.de>
Cc: Jerome Glisse <jglisse@redhat.com>,
 "linux-mm@kvack.org" <linux-mm@kvack.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 "Rafael J . Wysocki" <rafael@kernel.org>, Bjorn Helgaas
 <bhelgaas@google.com>, Christian Koenig <christian.koenig@amd.com>,
 Felix Kuehling <Felix.Kuehling@amd.com>,
 "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
 "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
 Marek Szyprowski <m.szyprowski@samsung.com>,
 Robin Murphy <robin.murphy@arm.com>, Joerg Roedel <jroedel@suse.de>,
 "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>
References: <20190129193250.GK10108@mellanox.com>
 <99c228c6-ef96-7594-cb43-78931966c75d@deltatee.com>
 <20190129205749.GN3176@redhat.com>
 <2b704e96-9c7c-3024-b87f-364b9ba22208@deltatee.com>
 <20190129215028.GQ3176@redhat.com>
 <deb7ba21-77f8-0513-2524-ee40a8ee35d5@deltatee.com>
 <20190129234752.GR3176@redhat.com>
 <655a335c-ab91-d1fc-1ed3-b5f0d37c6226@deltatee.com>
 <20190130041841.GB30598@mellanox.com> <20190130080006.GB29665@lst.de>
 <20190130190651.GC17080@mellanox.com>
From: Logan Gunthorpe <logang@deltatee.com>
Message-ID: <840256f8-0714-5d7d-e5f5-c96aec5c2c05@deltatee.com>
Date: Wed, 30 Jan 2019 12:45:46 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190130190651.GC17080@mellanox.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-SA-Exim-Connect-IP: 68.147.80.180
X-SA-Exim-Rcpt-To: iommu@lists.linux-foundation.org, jroedel@suse.de, robin.murphy@arm.com, m.szyprowski@samsung.com, dri-devel@lists.freedesktop.org, linux-pci@vger.kernel.org, Felix.Kuehling@amd.com, christian.koenig@amd.com, bhelgaas@google.com, rafael@kernel.org, gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jglisse@redhat.com, hch@lst.de, jgg@mellanox.com
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



On 2019-01-30 12:06 p.m., Jason Gunthorpe wrote:
>> Way less problems than not having struct page for doing anything
>> non-trivial.  If you map the BAR to userspace with remap_pfn_range
>> and friends the mapping is indeed very simple.  But any operation
>> that expects a page structure, which is at least everything using
>> get_user_pages won't work.
> 
> GUP doesn't work anyhow today, and won't work with BAR struct pages in
> the forseeable future (Logan has sent attempts on this before).

I don't recall ever attempting that... But patching GUP for special
pages or VMAS; or working around by not calling it in some cases seems
like the thing that's going to need to be done one way or another.

> Jerome made the HMM mirror API use this flow, so afer his patch to
> switch the ODP MR to use HMM, and to switch GPU drivers, it will work
> for those cases. Which is more than the zero cases than we have today
> :)

But we're getting the same bait and switch here... If you are using HMM
you are using struct pages, but we're told we need this special VMA hack
for cases that don't use HMM and thus don't have struct pages...

Logan

