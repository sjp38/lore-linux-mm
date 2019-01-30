Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8D80EC3E8A4
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 19:53:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3F09620989
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 19:53:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3F09620989
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=deltatee.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EAEE48E0019; Wed, 30 Jan 2019 14:53:00 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E5DA88E0001; Wed, 30 Jan 2019 14:53:00 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D74AB8E0019; Wed, 30 Jan 2019 14:53:00 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id AFC278E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 14:53:00 -0500 (EST)
Received: by mail-io1-f69.google.com with SMTP id s5so487481iom.22
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 11:53:00 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding:subject;
        bh=UZOyb2K3qZ3k2izC2QpfIelAk/lnLJm+DT4s53M75qg=;
        b=LEWVAv6JMEdS487qgUqkL7SKexZLSxmiJ0dADBrjwA5uqE7Pmiz6YCNNIQTs/GciC9
         ozwW2XVyZk9jifK7very8cMhP5eYqDS9sXNR/j/fSC8Rw4NP0Mt8lCBo9v6f8nLmS+LC
         W0yiSOcmc8X+LqIGgVCvJrqAu6jT/pEF7xXAZEyolfi7rDhCDr388FR14Dc6/wBQzb7H
         J57n/fzzmrW09i5gZK5sRyLOJVRzqMHgxc+VWodNZrqfoGrJF3+664CVVhOL42YkoBiD
         g1OvOwEVuPt35SysSUZDUfqhs1aaARGMqD4XXdvNgoAOSvF/uRNnzkQk8wAwy8PLA55w
         tE7Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) smtp.mailfrom=logang@deltatee.com
X-Gm-Message-State: AHQUAuZPtEs32D5S/YGn8GhLpaKIE9/zNTC3wC9lUKLxrH3xUP4JuhnV
	MkhGPp+kLtGHJ8tMXN2XSHdu81tiafsclfhG2eZYlJvPKMWNn2i7dr7eea7TNeSXo1fzGbcAvNT
	7VjernEuC8bejbtJjpy7upcmwXsv4CRldJC/4pHxejI1NMbLbevk/XTOrgZ+wC6GhDQ==
X-Received: by 2002:a6b:9089:: with SMTP id s131mr4229409iod.242.1548877980426;
        Wed, 30 Jan 2019 11:53:00 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYEKmekZVQW95+2Su1SqYaOswbqu9NQlxt9Kt6OriXGpI9dYU1BBeioyV00si+Ms/jf0mnN
X-Received: by 2002:a6b:9089:: with SMTP id s131mr4229387iod.242.1548877979712;
        Wed, 30 Jan 2019 11:52:59 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548877979; cv=none;
        d=google.com; s=arc-20160816;
        b=wS/DCPUYSCKJ5fj70X7RqYDob6+vQvKE4MijAfWz2CWmORstJP2pqwJl8RPYdpfMSU
         tzMMf3q2q7sMrx+Vwa0YqrZ1+ub8IZSN3xIjNksZLZkVKpNmnsfenhqOY7ZJ5+9ZcH+x
         NGml9nX5+fYOtaGEXBAn5wCRWT3JXnVDLE/55pOKbjoJsHjkWWXcSMkk6CB3+yBbIehk
         OB7arIge1M3FsnEV9yMvwzCwoWqUX8LfnZ2R1xU6AIfJV8YLNf8NYpCPVyUnWmARMRva
         zlfTXrPg50yzTZOE8N1zocWYetrlnl7Pcfksh1KnB5CEaTQut3BynvwxlZ2SOrRETtMX
         Wa/g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=subject:content-transfer-encoding:content-language:in-reply-to
         :mime-version:user-agent:date:message-id:from:references:cc:to;
        bh=UZOyb2K3qZ3k2izC2QpfIelAk/lnLJm+DT4s53M75qg=;
        b=gEIyvwosLxfBHW6MF6zSx5YWp3fImTba851tuwabJXlo9oB0JV/SzVXR8J/nhkFOZY
         hKSO54cOZ5daPlgT4BzhsIl2/ihn5dPTGqG8WWStjTQg+QP9/oA1rb3xJnsjczDJvKu7
         0KVg73j9MHgjtc1gfiveO+dD4r8q1EFvqQuc7nCjAlWiF2mGcjYJgw+3kV9gXbVuhhMG
         4yDHFFHIgcPbY+cKS4kaq28Ujf6PFytigUyRW/5IvEJADgzSkxkLqgTIgNaHijw3VBwt
         ACdssIf/QmazSEjVpqUPlmuiz5l2rtBwifoaiH5lBRn/DkslozH9Vq94f7ued9/HJqOs
         SJ0w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) smtp.mailfrom=logang@deltatee.com
Received: from ale.deltatee.com (ale.deltatee.com. [207.54.116.67])
        by mx.google.com with ESMTPS id f203si1465728itd.62.2019.01.30.11.52.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 30 Jan 2019 11:52:59 -0800 (PST)
Received-SPF: pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) client-ip=207.54.116.67;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) smtp.mailfrom=logang@deltatee.com
Received: from s01061831bf6ec98c.cg.shawcable.net ([68.147.80.180] helo=[192.168.6.205])
	by ale.deltatee.com with esmtpsa (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128)
	(Exim 4.89)
	(envelope-from <logang@deltatee.com>)
	id 1govui-0008T2-Ew; Wed, 30 Jan 2019 12:52:49 -0700
To: Jerome Glisse <jglisse@redhat.com>, Jason Gunthorpe <jgg@mellanox.com>
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
References: <99c228c6-ef96-7594-cb43-78931966c75d@deltatee.com>
 <20190129205749.GN3176@redhat.com>
 <2b704e96-9c7c-3024-b87f-364b9ba22208@deltatee.com>
 <20190129215028.GQ3176@redhat.com>
 <deb7ba21-77f8-0513-2524-ee40a8ee35d5@deltatee.com>
 <20190129234752.GR3176@redhat.com>
 <655a335c-ab91-d1fc-1ed3-b5f0d37c6226@deltatee.com>
 <20190130041841.GB30598@mellanox.com>
 <bdf03cd5-f5b1-4b78-a40e-b24024ca8c9f@deltatee.com>
 <20190130185652.GB17080@mellanox.com> <20190130192234.GD5061@redhat.com>
From: Logan Gunthorpe <logang@deltatee.com>
Message-ID: <5a60507e-e781-d0a4-353e-32105ca7ace3@deltatee.com>
Date: Wed, 30 Jan 2019 12:52:44 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190130192234.GD5061@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
X-SA-Exim-Connect-IP: 68.147.80.180
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



On 2019-01-30 12:22 p.m., Jerome Glisse wrote:
> On Wed, Jan 30, 2019 at 06:56:59PM +0000, Jason Gunthorpe wrote:
>> On Wed, Jan 30, 2019 at 10:17:27AM -0700, Logan Gunthorpe wrote:
>>>
>>>
>>> On 2019-01-29 9:18 p.m., Jason Gunthorpe wrote:
>>>> Every attempt to give BAR memory to struct page has run into major
>>>> trouble, IMHO, so I like that this approach avoids that.
>>>>
>>>> And if you don't have struct page then the only kernel object left to
>>>> hang meta data off is the VMA itself.
>>>>
>>>> It seems very similar to the existing P2P work between in-kernel
>>>> consumers, just that VMA is now mediating a general user space driven
>>>> discovery process instead of being hard wired into a driver.
>>>
>>> But the kernel now has P2P bars backed by struct pages and it works
>>> well. 
>>
>> I don't think it works that well..
>>
>> We ended up with a 'sgl' that is not really a sgl, and doesn't work
>> with many of the common SGL patterns. sg_copy_buffer doesn't work,
>> dma_map, doesn't work, sg_page doesn't work quite right, etc.
>>
>> Only nvme and rdma got the special hacks to make them understand these
>> p2p-sgls, and I'm still not convinced some of the RDMA drivers that
>> want access to CPU addresses from the SGL (rxe, usnic, hfi, qib) don't
>> break in this scenario.
>>
>> Since the SGLs become broken, it pretty much means there is no path to
>> make GUP work generically, we have to go through and make everything
>> safe to use with p2p-sgls before allowing GUP. Which, frankly, sounds
>> impossible with all the competing objections.
>>
>> But GPU seems to have a problem unrelated to this - what Jerome wants
>> is to have two faulting domains for VMA's - visible-to-cpu and
>> visible-to-dma. The new op is essentially faulting the pages into the
>> visible-to-dma category and leaving them invisible-to-cpu.
>>
>> So that duality would still have to exists, and I think p2p_map/unmap
>> is a much simpler implementation than trying to create some kind of
>> special PTE in the VMA..
>>
>> At least for RDMA, struct page or not doesn't really matter. 
>>
>> We can make struct pages for the BAR the same way NVMe does.  GPU is
>> probably the same, just with more mememory at stake?  
>>
>> And maybe this should be the first implementation. The p2p_map VMA
>> operation should return a SGL and the caller should do the existing
>> pci_p2pdma_map_sg() flow.. 
> 
> For GPU it would not work, GPU might want to use main memory (because
> it is running out of BAR space) it is a lot easier if the p2p_map
> callback calls the right dma map function (for page or io) rather than
> having to define some format that would pass down the information.

>>
>> Worry about optimizing away the struct page overhead later?
> 
> Struct page do not fit well for GPU as the BAR address can be reprogram
> to point to any page inside the device memory (think 256M BAR versus
> 16GB device memory). Forcing struct page on GPU driver would require
> major surgery to the GPU driver inner working and there is no benefit
> to have from the struct page. So it is hard to justify this.

I think we have to consider the struct pages to track the address space,
not what backs it (essentially what HMM is doing). If we need to add
operations for the driver to map the address space/struct pages back to
physical memory then do that. Creating a whole new idea that's tied to
userspace VMAs still seems wrong to me.

Logan

