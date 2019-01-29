Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 05C85C282C7
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 21:31:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BDDBD2087E
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 21:31:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BDDBD2087E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=deltatee.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5F52D8E0002; Tue, 29 Jan 2019 16:31:04 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 57A138E0001; Tue, 29 Jan 2019 16:31:04 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 441BD8E0002; Tue, 29 Jan 2019 16:31:04 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id 17CA08E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 16:31:04 -0500 (EST)
Received: by mail-it1-f197.google.com with SMTP id m128so16682414itd.3
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 13:31:04 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding:subject;
        bh=BdHbW7o22HIfGup05BEnYLLdHP6BmzGou5QMJCoRCI8=;
        b=ddkbiKaD81FHARlgyNroLH1K6kSgMUe32o4OdRGVW6vkS5vy9YWQAVKe78Oc6TIOQG
         2chm+FI9ax6SPdBtQ+0Vvt4VwEEH0VJY/1KCwgdXnq24eC7ChyAjsAnuAxW+LLJs6q82
         /Gq0k2sgwM5eVzEld9TdspdliqQkrgm4+TtuF1oxqIr80fhyDXI54XSEWSAOWxuvV/X1
         8bAQdiiWkRCoT9y9/ccmLoqSYcBn2eRx+DdRSAMsXWfXCdipmzlsPgTCE54BViVFiZSw
         Db2iULzf3HK9UPc3sbb1POLr9GWSHhNuMjuP07a90wbONHgnkiLTVQZF0mHe5BDuovTj
         KzFg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) smtp.mailfrom=logang@deltatee.com
X-Gm-Message-State: AJcUukdXEayZnaaq80uH/RT6eD6TAtQs3b8pL1JEFWr8P+Z+TQ211GCq
	CfQwHYa0/BiI3k8f7xknDEIALtFcDkJLfX7So/Z9czJBO3nHhr9YLqDDlN1OZZJ4/XUbCgCMLG2
	Fkd3viMu5CHUS/b+JxdTLfqSrzEtF0b+NAE3HiU/03f+UiEOcII+l61PLuZnhIMUuVw==
X-Received: by 2002:a24:414c:: with SMTP id x73mr13429887ita.129.1548797463852;
        Tue, 29 Jan 2019 13:31:03 -0800 (PST)
X-Google-Smtp-Source: ALg8bN52f2x07zVouv28RI29GERwfnJZa+AJ5W4mM6799HdNBpD8Fojgj0NnMXq/3cKeweq25R5K
X-Received: by 2002:a24:414c:: with SMTP id x73mr13429856ita.129.1548797462983;
        Tue, 29 Jan 2019 13:31:02 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548797462; cv=none;
        d=google.com; s=arc-20160816;
        b=hr1SyHiDp38LeBxo7xrADHnzjgvksxBY3tNgJG/1X5Xe+KiFrxOxvWEsWtbIyWDP3u
         9T0ZIuj3wz+PJFK1EnVMXUKcjZnB21jF92pBVDHQmQ+gd0uaGSVKIk6OSuFxzIjf6s8Z
         USFKwkUl6g/UMhuuQ3z9vTNXQA3Bt8Zp21yEKJ+2Yr7AMaeZbyCECJPySprIFYatlSug
         SEHvHDXIK9kk2KfpMjFAVC05Qc+GZZwPv59zP6hbf//UpzXcgE+20fGbZnSWCPLRx4P/
         P80lDimcr/RwLqhRu6FAMtK+1mdZswsLtF9fkprrGrAAm0xk4z5qNn1istSpAcIVgS7l
         GXPg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=subject:content-transfer-encoding:content-language:in-reply-to
         :mime-version:user-agent:date:message-id:from:references:cc:to;
        bh=BdHbW7o22HIfGup05BEnYLLdHP6BmzGou5QMJCoRCI8=;
        b=XGilXdNX11sn549BD0QZ23T52nAgIB7yNE0azk2W2t5Pf3g9dGzbnOzYR9MaD2GjAu
         3LKWJ02752AgzP96YLT7Z+wwOVRgI4H5cTi/1lhKDfz1mxejqlYyxKfEBWhmxWxWxxyi
         SEC8Q6qa8SWqcVlpWEyfxGNwhAY29+DW5ZLNWCVzxjpFdyVlROd6xGnwr6nNTPQZ+/BM
         Tg/9RKgOwHli9fOU8RHVrnqWfA8uKrmIDmkQkhi8mrM5e0a1lkcNRvy7ytc+LgVrc4uk
         uNUJASt8M6ks4FwjK/S+g6NNVPtNYmdiZP3NqqRsZuoRP/4fKMFgBYe8SEOm8CQ3Lpw1
         JO1A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) smtp.mailfrom=logang@deltatee.com
Received: from ale.deltatee.com (ale.deltatee.com. [207.54.116.67])
        by mx.google.com with ESMTPS id q11si1069294itj.144.2019.01.29.13.31.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 29 Jan 2019 13:31:02 -0800 (PST)
Received-SPF: pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) client-ip=207.54.116.67;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) smtp.mailfrom=logang@deltatee.com
Received: from guinness.priv.deltatee.com ([172.16.1.162])
	by ale.deltatee.com with esmtp (Exim 4.89)
	(envelope-from <logang@deltatee.com>)
	id 1goay3-0007MV-KB; Tue, 29 Jan 2019 14:30:52 -0700
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
From: Logan Gunthorpe <logang@deltatee.com>
Message-ID: <2b704e96-9c7c-3024-b87f-364b9ba22208@deltatee.com>
Date: Tue, 29 Jan 2019 14:30:49 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190129205749.GN3176@redhat.com>
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



On 2019-01-29 1:57 p.m., Jerome Glisse wrote:
> GPU driver must be in control and must be call to. Here there is 2 cases
> in this patchset and i should have instead posted 2 separate patchset as
> it seems that it is confusing things.
> 
> For the HMM page, the physical address of the page ie the pfn does not
> correspond to anything ie there is nothing behind it. So the importing
> device has no idea how to get a valid physical address from an HMM page
> only the device driver exporting its memory with HMM device memory knows
> that.
> 
> 
> For the special vma ie mmap of a device file. GPU driver do manage their
> BAR ie the GPU have a page table that map BAR page to GPU memory and the
> driver _constantly_ update this page table, it is reflected by invalidating
> the CPU mapping. In fact most of the time the CPU mapping of GPU object are
> invalid they are valid only a small fraction of their lifetime. So you
> _must_ have some call to inform the exporting device driver that another
> device would like to map one of its vma. The exporting device can then
> try to avoid as much churn as possible for the importing device. But this
> has consequence and the exporting device driver must be allow to apply
> policy and make decission on wether or not it authorize the other device
> to peer map its memory. For GPU the userspace application have to call
> specific API that translate into specific ioctl which themself set flags
> on object (in the kernel struct tracking the user space object). The only
> way to allow program predictability is if the application can ask and know
> if it can peer export an object (ie is there enough BAR space left).

This all seems like it's an HMM problem and not related to mapping
BARs/"potential BARs" to userspace. If some code wants to DMA map HMM
pages, it calls an HMM function to map them. If HMM needs to consult
with the driver on aspects of how that's mapped, then that's between HMM
and the driver and not something I really care about. But making the
entire mapping stuff tied to userspace VMAs does not make sense to me.
What if somebody wants to map some HMM pages in the same way but from
kernel space and they therefore don't have a VMA?


>> I also figured there'd be a fault version of p2p_ioremap_device_memory()
>> for when you are mapping P2P memory and you want to assign the pages
>> lazily. Though, this can come later when someone wants to implement that.
> 
> For GPU the BAR address space is manage page by page and thus you do not
> want to map a range of BAR addresses but you want to allow mapping of
> multiple page of BAR address that are not adjacent to each other nor
> ordered in anyway. But providing helper for simpler device does make sense.

Well, this has little do with the backing device but how the memory is
mapped into userspace. With p2p_ioremap_device_memory() the entire range
is mapped into the userspace VMA immediately during the call to mmap().
With p2p_fault_device_memory(), mmap() would not actually map anything
and a page in the VMA would be mapped only when userspace accesses it
(using fault()). It seems to me like GPUs would prefer the latter but if
HMM takes care of the mapping from userspace potential pages to actual
GPU pages through the BAR then that may not be true.

Logan

