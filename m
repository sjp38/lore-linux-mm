Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 65429C282C7
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 20:40:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2A8D62087E
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 20:40:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2A8D62087E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=deltatee.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C32628E0002; Tue, 29 Jan 2019 15:40:02 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BBA4C8E0001; Tue, 29 Jan 2019 15:40:02 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A83288E0002; Tue, 29 Jan 2019 15:40:02 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6C92D8E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 15:40:02 -0500 (EST)
Received: by mail-io1-f71.google.com with SMTP id s5so17493755iom.22
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 12:40:02 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding:subject;
        bh=D6ftez5nRx/sknuHk55FUizzDioe3nrsbEAHpQ5CoHU=;
        b=SOgcB8557CGxCopghkFU+IMQpRNqWog3EOYmCgUkLgiI95Akft90DYjxFom4HbEZC7
         +VMbPXpzXvL+035D8ToNW1V0oCyCheFav/OCJgNdriX+An/JO/uYZNe0ZkFEgfF61NjI
         ZzkSfikOSC4WoMnIiTBnIpOLlU2qZHSYHZxukfuZRrlPcq+SNNfuD+sBGT+UAjik4oLF
         R4LltXS8546AFwvPxLCW/6M3LUo9eekwtp1WGU0BlhWzTw8Pgl8aZguOLg9kXoHXoiFA
         RgGpcF43wKMUW5tiQwlS3G1Kt6zX0xXWzaIbSLs+wksI4qGEw++ijsOvYhIObuTv04Ci
         EQUQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) smtp.mailfrom=logang@deltatee.com
X-Gm-Message-State: AJcUukcjfMHv2dKQ7NZjdkGsaU5mt9nqbnvWeQ0Bc5sv4uTBfJANUZGx
	f8BjwG7CTCHG5UWgS1QMNCyJDzRyy6s8hQKtruKtwTQDI8o7vQ/DLt8jihB9Wb67YWgkxxlKkyv
	5o0nSAi47uASFWN9LvoexzOkfSiLg8XbLH25U3Ee5ycCRUxEL1gb9ryAmbdm9q5EwSg==
X-Received: by 2002:a24:2f82:: with SMTP id j124mr12492640itj.166.1548794402169;
        Tue, 29 Jan 2019 12:40:02 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5qy+TSazk/TCfOFgfwigDhgjvkBYHrrncn9y6hKUvJJKgarUD72B0SlC0CcLISU7Sb/Iru
X-Received: by 2002:a24:2f82:: with SMTP id j124mr12492623itj.166.1548794401577;
        Tue, 29 Jan 2019 12:40:01 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548794401; cv=none;
        d=google.com; s=arc-20160816;
        b=RxO6Jy+Tml/zc41m/YA8tFFgTjS46AtFhvQPo5FkyMONSm+uqBR/DzlTQQ2ZJp7Dxy
         PwMczCYtBv9usM18rxxIjkYshRRZ2k86aM7mXhajDsbMqq4HOcdko5/w73USYmaRse6K
         wDfZCUqIffP7KrZAL8XaDenOPChI7aYNGhrhSqv9bQX6tE0xJuVJK13UGX/EHjHauntT
         oTHB8unTDSTnNt+qMpYqtHlMwY+LqZTVxpKUsITfuz8HWgUHYqtF8NULHJLBhTOBQowC
         9a6wxK3U8xaTHrg/3fUayMwrrFLFeLT3/2cH/U7PPn1CZMq2DE0L7rFqC29B/ovsa82c
         MiAA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=subject:content-transfer-encoding:content-language:in-reply-to
         :mime-version:user-agent:date:message-id:from:references:cc:to;
        bh=D6ftez5nRx/sknuHk55FUizzDioe3nrsbEAHpQ5CoHU=;
        b=y55IcJRIi9WlHTJV4hze9Xvt+Bp1nIJ/PGr+/YqkKNeoqj/0crcw4rrcta/QRD00op
         PU7l688YzBMj5phwLk8LXiHTOp5PO1eoi62Ov6vluopNnIG3522fJXEUDJYHwJMA359C
         mvZoTf8WF+oJhfxOtgnyoxETrYCbCEZYFM7LHhG6MSI0dy+DHrYgAa/f41R4TBzCBfSO
         lAbPYKnW3F9/4puZOwiB/UnZQ6cgzWJyEufZlmBOZv9sugnMBXKfMnjQfIYyLfuVd3BQ
         9K44LbipTmM4nGwq9oAMzbmcDSB8nPGCW5RMKFO8Kivx12gnCiV6fwXu9zNh9hxz+1bE
         7DZQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) smtp.mailfrom=logang@deltatee.com
Received: from ale.deltatee.com (ale.deltatee.com. [207.54.116.67])
        by mx.google.com with ESMTPS id j82si613532itb.63.2019.01.29.12.40.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 29 Jan 2019 12:40:01 -0800 (PST)
Received-SPF: pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) client-ip=207.54.116.67;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) smtp.mailfrom=logang@deltatee.com
Received: from guinness.priv.deltatee.com ([172.16.1.162])
	by ale.deltatee.com with esmtp (Exim 4.89)
	(envelope-from <logang@deltatee.com>)
	id 1goaAh-0006hr-4u; Tue, 29 Jan 2019 13:39:51 -0700
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
References: <20190129174728.6430-1-jglisse@redhat.com>
 <20190129174728.6430-4-jglisse@redhat.com>
 <ae928aa5-a659-74d5-9734-15dfefafd3ea@deltatee.com>
 <20190129191120.GE3176@redhat.com> <20190129193250.GK10108@mellanox.com>
From: Logan Gunthorpe <logang@deltatee.com>
Message-ID: <99c228c6-ef96-7594-cb43-78931966c75d@deltatee.com>
Date: Tue, 29 Jan 2019 13:39:49 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190129193250.GK10108@mellanox.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-CA
Content-Transfer-Encoding: 7bit
X-SA-Exim-Connect-IP: 172.16.1.162
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



On 2019-01-29 12:32 p.m., Jason Gunthorpe wrote:
> Jerome, I think it would be nice to have a helper scheme - I think the
> simple case would be simple remapping of PCI BAR memory, so if we
> could have, say something like:
> 
> static const struct vm_operations_struct my_ops {
>   .p2p_map = p2p_ioremap_map_op,
>   .p2p_unmap = p2p_ioremap_unmap_op,
> }
> 
> struct ioremap_data {
>   [..]
> }
> 
> fops_mmap() {
>    vma->private_data = &driver_priv->ioremap_data;
>    return p2p_ioremap_device_memory(vma, exporting_device, [..]);
> }

This is roughly what I was expecting, except I don't see exactly what
the p2p_map and p2p_unmap callbacks are for. The importing driver should
see p2pdma/hmm struct pages and use the appropriate function to map
them. It shouldn't be the responsibility of the exporting driver to
implement the mapping. And I don't think we should have 'special' vma's
for this (though we may need something to ensure we don't get mapping
requests mixed with different types of pages...).

I also figured there'd be a fault version of p2p_ioremap_device_memory()
for when you are mapping P2P memory and you want to assign the pages
lazily. Though, this can come later when someone wants to implement that.

Logan

