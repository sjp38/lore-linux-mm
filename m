Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E1AA0C282D0
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 01:18:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A515C21473
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 01:18:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A515C21473
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=deltatee.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3E7E38E0009; Tue, 29 Jan 2019 20:18:00 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 370218E0001; Tue, 29 Jan 2019 20:18:00 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 23A068E0009; Tue, 29 Jan 2019 20:18:00 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id EDDC88E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 20:17:59 -0500 (EST)
Received: by mail-io1-f72.google.com with SMTP id q23so18155247ior.6
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 17:17:59 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding:subject;
        bh=d0hqJBNO/ehDEoDh0aiZqq406rzWFwWHaEXfTA/EhkQ=;
        b=rYdk5wa0+4gIvy6i/sIEDMjjZvX+tL2CNByCjltZM6y37xoRysCVkBWJhUvw5xNTsR
         goEGm2uj7hmENu4E8rm1NOdXWnLCrbGApiu1Z1O0Zkd4UXCt0RIUIl5F0DGUvYiAwn7w
         wUHOFCQR6FZaq97kG0IQajLR2c+xDC5UxRwgIU8Iso108hvrELA+Q1HmHHpcyVNWqbpc
         vTxFHN4pERD2bUaWdankqtiEikU5AVLfRfpDdzEmbn3Nwzn7Brtp9hzvoIrrWF67CzsE
         YRx16Ou3xJVDT2fgVlJMLipZcKSuikoleIG/EFYPw4BvbCAa5IfUS4LF/TLLzqc9H/69
         SRlw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) smtp.mailfrom=logang@deltatee.com
X-Gm-Message-State: AJcUukc8i/o2Q1CJL42YSGeEGDs+mOL++6F0c8IcWEE+KbH5mPXNyLz/
	JH8cxw4KmOmKN3xW/TeyYV8/mbHK7tLrbjIDucx8DMy5OEwjqWe28Lg7O60DqF1JSSP2IuazP8S
	Qk4wwy9DVQOepo+a6mZxoaTWDy1oh14Sl/ZAoHZco0XgfCiRaypJF3REFcl7YfejiKw==
X-Received: by 2002:a24:710:: with SMTP id f16mr12690709itf.121.1548811079744;
        Tue, 29 Jan 2019 17:17:59 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7KxQjgHo5N08y8ratzDIhuQlDhlXQrjkR2QJ5wUJHJGGLnhZKmBEuPUddJofbmz7TDKX4h
X-Received: by 2002:a24:710:: with SMTP id f16mr12690693itf.121.1548811078926;
        Tue, 29 Jan 2019 17:17:58 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548811078; cv=none;
        d=google.com; s=arc-20160816;
        b=0OxmWmVPLNeB8/j1NFh0xo6PEv+v8qhPdPk8TCjRe303UN6JVeNw19YyYhhMkrK70n
         33UOxfUQkFMIjQbOW/SGirfJIaZ4YhyiPb/XoVIFivikVnUkSAKjJB0jn3XEX/Ha6g+/
         HVl1tG1gg6999zOz0d4zf9dZoaQ0ABLbtLnbPSZniwaTXJDzB/+DkHkZqbVmZkrjIpPv
         FNQhz7cct9n5LymiH2JX5g1zlCAypoTcMdvsApGqdHebu0t25t5uBl2eMDxFpvE/EW9+
         pL91XIkVFFm4cmSWHm7ZmsiRwCU2wdY5j6B3HeeG6E274dCYfG7DTMkpomGTo4vDH7Ql
         aBXA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=subject:content-transfer-encoding:content-language:in-reply-to
         :mime-version:user-agent:date:message-id:from:references:cc:to;
        bh=d0hqJBNO/ehDEoDh0aiZqq406rzWFwWHaEXfTA/EhkQ=;
        b=zUfmGnkAogqvfIZ0NrtaXiFQajk2SNU7bgbBWN0L6zHOfXGM5XxVgBORaJ+X04Xcwz
         jymNDlLAPfPz7s+bhR+8G2b7oEKJxaJJG/lOQNcB6R8VpqpHaWCJ/3Qz50zfXMnkGC+V
         rt2taLw3NAiPq4pwlaWxsXpQTQWToql6zHztgScfWt/cEjcsaz0DoYPpuimsmad9Yog7
         6j/iSP/ApTiQVFYxCJvRNHyC7zExUNKiMrncTAaPF9VBg/LJPQONYegUnGZKB+6ZyI6Y
         Lapp55yIfTXTfErm9fWcjwplKaYyYMGrXuAKgpHbMS4NgLaM7k6Atmd/PvjKjwnNxoAo
         67lw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) smtp.mailfrom=logang@deltatee.com
Received: from ale.deltatee.com (ale.deltatee.com. [207.54.116.67])
        by mx.google.com with ESMTPS id 187si18571iou.90.2019.01.29.17.17.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 29 Jan 2019 17:17:58 -0800 (PST)
Received-SPF: pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) client-ip=207.54.116.67;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) smtp.mailfrom=logang@deltatee.com
Received: from guinness.priv.deltatee.com ([172.16.1.162])
	by ale.deltatee.com with esmtp (Exim 4.89)
	(envelope-from <logang@deltatee.com>)
	id 1goeVd-0001rh-FE; Tue, 29 Jan 2019 18:17:46 -0700
To: Jerome Glisse <jglisse@redhat.com>
Cc: Jason Gunthorpe <jgg@mellanox.com>,
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
References: <20190129174728.6430-1-jglisse@redhat.com>
 <20190129174728.6430-4-jglisse@redhat.com>
 <ae928aa5-a659-74d5-9734-15dfefafd3ea@deltatee.com>
 <20190129191120.GE3176@redhat.com> <20190129193250.GK10108@mellanox.com>
 <99c228c6-ef96-7594-cb43-78931966c75d@deltatee.com>
 <20190129205749.GN3176@redhat.com>
 <2b704e96-9c7c-3024-b87f-364b9ba22208@deltatee.com>
 <20190129215028.GQ3176@redhat.com>
 <deb7ba21-77f8-0513-2524-ee40a8ee35d5@deltatee.com>
 <20190129234752.GR3176@redhat.com>
From: Logan Gunthorpe <logang@deltatee.com>
Message-ID: <655a335c-ab91-d1fc-1ed3-b5f0d37c6226@deltatee.com>
Date: Tue, 29 Jan 2019 18:17:43 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190129234752.GR3176@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-CA
Content-Transfer-Encoding: 7bit
X-SA-Exim-Connect-IP: 172.16.1.162
X-SA-Exim-Rcpt-To: iommu@lists.linux-foundation.org, jroedel@suse.de, robin.murphy@arm.com, m.szyprowski@samsung.com, hch@lst.de, dri-devel@lists.freedesktop.org, linux-pci@vger.kernel.org, Felix.Kuehling@amd.com, christian.koenig@amd.com, bhelgaas@google.com, rafael@kernel.org, gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jgg@mellanox.com, jglisse@redhat.com
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



On 2019-01-29 4:47 p.m., Jerome Glisse wrote:
> The whole point is to allow to use device memory for range of virtual
> address of a process when it does make sense to use device memory for
> that range. So they are multiple cases where it does make sense:
> [1] - Only the device is accessing the range and they are no CPU access
>       For instance the program is executing/running a big function on
>       the GPU and they are not concurrent CPU access, this is very
>       common in all the existing GPGPU code. In fact AFAICT It is the
>       most common pattern. So here you can use HMM private or public
>       memory.
> [2] - Both device and CPU access a common range of virtul address
>       concurrently. In that case if you are on a platform with cache
>       coherent inter-connect like OpenCAPI or CCIX then you can use
>       HMM public device memory and have both access the same memory.
>       You can not use HMM private memory.
> 
> So far on x86 we only have PCIE and thus so far on x86 we only have
> private HMM device memory that is not accessible by the CPU in any
> way.

I feel like you're just moving the rug out from under us... Before you
said ignore HMM and I was asking about the use case that wasn't using
HMM and how it works without HMM. In response, you just give me *way*
too much information describing HMM. And still, as best as I can see,
managing DMA mappings (which is different from the userspace mappings)
for GPU P2P should be handled by HMM and the userspace mappings should
*just* link VMAs to HMM pages using the standard infrastructure we
already have.

>> And what struct pages are actually going to be backing these VMAs if
>> it's not using HMM?
> 
> When you have some range of virtual address migrated to HMM private
> memory then the CPU pte are special swap entry and they behave just
> as if the memory was swapped to disk. So CPU access to those will
> fault and trigger a migration back to main memory.

This isn't answering my question at all... I specifically asked what is
backing the VMA when we are *not* using HMM.

Logan

