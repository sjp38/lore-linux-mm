Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E17FEC3E8A4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 22:59:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A3BE22147A
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 22:59:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A3BE22147A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=deltatee.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3411E8E0004; Tue, 29 Jan 2019 17:59:02 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2C69A8E0001; Tue, 29 Jan 2019 17:59:02 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 167608E0004; Tue, 29 Jan 2019 17:59:02 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id E15308E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 17:59:01 -0500 (EST)
Received: by mail-io1-f70.google.com with SMTP id r65so17748228iod.12
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 14:59:01 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding:subject;
        bh=/HjFY2seYMPvQ4M3/yxiG+mYfSQ9XoLqMI3FGZ7LxXU=;
        b=EltaSSMW6wRU0DJFuH7LTZcz3l6PdUbjfLESOBuPLufawZRlz4IJhLiHQr5VzEj7a9
         fFG7d8cG6Nk97cDI20u7y4DNm0fwHCWYfsxg5rgkBPV52EKFRQHWosuk55ADAHmhXM0m
         9LPyp63u0D957XYEUP6pXV78IzKi5OaJHPgNLjWlu0O35mPvtPUppP8kvPsdlb0kEbXB
         rz030jsqXqzkZAoEB6VtAeQeXdlYBzsb47omxtqXg7I0+qLpjyxTSjUdCPIsEhZE8f06
         PoSuCk1ZLR4YN4hPQjfxxt3gjsPUeeoXaLyEyUpyWeDgNL+92M9S8cWAs/htKdo/Msrv
         w3iQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) smtp.mailfrom=logang@deltatee.com
X-Gm-Message-State: AJcUukeCOk38IgSu2D2K/GM94omvSQBG8lAOxYseA3edz5oCf7R0Gfj6
	zrkC9qWWmB2zyvXCD5i02LxCGWitU1zFbdp2PI4rJ3d16umDtwjUP2t+qmaKuq56qzfTElLHWmx
	kIp9vhMbyGI8TvOnE8Et0jmHDgb9arfcyNLQPmic0Q4vlQcfB80k67o/ZXsEW/PV3/Q==
X-Received: by 2002:a24:2f82:: with SMTP id j124mr12731191itj.166.1548802741685;
        Tue, 29 Jan 2019 14:59:01 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4bc+ZqC37dOMO0bEIZRq0Q+fZR7mKLUhDX2oWDx4qUyPmkC+MYy3WQiude18VtZBk3kJFV
X-Received: by 2002:a24:2f82:: with SMTP id j124mr12731175itj.166.1548802740986;
        Tue, 29 Jan 2019 14:59:00 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548802740; cv=none;
        d=google.com; s=arc-20160816;
        b=qvJd3hIVOghRWHC1TCtV4aboYPtBtBkPKVqV8QneaLcrw8JZOcM6o3k4uSwGutnnlE
         2oRyRHXywcyICRxcbKN8MjTQZ+MjVfJk3E+s7PRtsaHPmmrQ5bVT7H1GtBTtHARDEmH/
         T1dSfyjLyMWQtCHZbEqiHXJSFD1EyZftJGj3mMfLGofKvJvTgDHkyDu+ZDFCm23hYWsD
         VhtsjehP7WRpOlXBIzMAJVXWeNeidzqCqSYJrZwBtHACkpyzXhPulioB0w2Y/sXy6Zfq
         nuDj8wZXhbmnxuYik77SJPDBzMbAzDccqe+AExbaQsIaIihtzJbOvbiSx98gmYF/DmMR
         2wOw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=subject:content-transfer-encoding:content-language:in-reply-to
         :mime-version:user-agent:date:message-id:from:references:cc:to;
        bh=/HjFY2seYMPvQ4M3/yxiG+mYfSQ9XoLqMI3FGZ7LxXU=;
        b=ieN/dzXpTXXIvSrw3rDlVX2wIvAxXQV7AHwV/Ogb8zPzwihPMBiE2G2XbCz98M61fl
         RNpslvVItr1TOZBgP34J0wWWbNY0x0cfgQfeAgZnVr4/TH1Kd4vCNsfvMvzT4KRvlDvo
         HwU9V4/Uma+QClhbfTqFbSVSdiDlqugB2DaQk+sHPiah60XqfgwVhJRpjvDwL5lkfSGb
         jSifjXyN6ch7r3R87tlsaG2IaeZk3AvwU1dIeZSCGezbzaPHYB8wI69zsG2fHqZc/vMX
         eLY25ZEY9LvrgX8pJM03Hoku8hYak+jCgCaEFLSWjORKn70lZJQglM/3IBEWXIE+R8pE
         7f3Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) smtp.mailfrom=logang@deltatee.com
Received: from ale.deltatee.com (ale.deltatee.com. [207.54.116.67])
        by mx.google.com with ESMTPS id t184si109183itd.129.2019.01.29.14.59.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 29 Jan 2019 14:59:00 -0800 (PST)
Received-SPF: pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) client-ip=207.54.116.67;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) smtp.mailfrom=logang@deltatee.com
Received: from guinness.priv.deltatee.com ([172.16.1.162])
	by ale.deltatee.com with esmtp (Exim 4.89)
	(envelope-from <logang@deltatee.com>)
	id 1gocL9-0008ND-Kp; Tue, 29 Jan 2019 15:58:48 -0700
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
From: Logan Gunthorpe <logang@deltatee.com>
Message-ID: <deb7ba21-77f8-0513-2524-ee40a8ee35d5@deltatee.com>
Date: Tue, 29 Jan 2019 15:58:45 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190129215028.GQ3176@redhat.com>
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



On 2019-01-29 2:50 p.m., Jerome Glisse wrote:
> No this is the non HMM case i am talking about here. Fully ignore HMM
> in this frame. A GPU driver that do not support or use HMM in anyway
> has all the properties and requirement i do list above. So all the points
> i was making are without HMM in the picture whatsoever. I should have
> posted this a separate patches to avoid this confusion.
> 
> Regarding your HMM question. You can not map HMM pages, all code path
> that would try that would trigger a migration back to regular memory
> and will use the regular memory for CPU access.
> 

I thought this was the whole point of HMM... And eventually it would
support being able to map the pages through the BAR in cooperation with
the driver. If not, what's that whole layer for? Why not just have HMM
handle this situation?

And what struct pages are actually going to be backing these VMAs if
it's not using HMM?


> Again HMM has nothing to do here, ignore HMM it does not play any role
> and it is not involve in anyway here. GPU want to control what object
> they allow other device to access and object they do not allow. GPU driver
> _constantly_ invalidate the CPU page table and in fact the CPU page table
> do not have any valid pte for a vma that is an mmap of GPU device file
> for most of the vma lifetime. Changing that would highly disrupt and
> break GPU drivers. They need to control that, they need to control what
> to do if another device tries to peer map some of their memory. Hence
> why they need to implement the callback and decide on wether or not they
> allow the peer mapping or use device memory for it (they can decide to
> fallback to main memory).

But mapping is an operation of the memory/struct pages behind the VMA;
not of the VMA itself and I think that's evident by the code in that the
only way the VMA layer is involved is the fact that you're abusing
vm_ops by adding new ops there and calling it by other layers.

Logan

