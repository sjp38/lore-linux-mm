Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D317DC282D9
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 19:48:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9E17F2184D
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 19:48:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9E17F2184D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=deltatee.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 514698E0019; Wed, 30 Jan 2019 14:48:46 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4C4578E0001; Wed, 30 Jan 2019 14:48:46 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 38E118E0019; Wed, 30 Jan 2019 14:48:46 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id 0CA8A8E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 14:48:46 -0500 (EST)
Received: by mail-it1-f198.google.com with SMTP id o205so110379itc.2
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 11:48:46 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding:subject;
        bh=R0XqkFHvjJbmr89hBrYpg4+Bb0t2c0TP+VUWudgcqs0=;
        b=uJ/qksIgjznzhAN8cwNNPg6cp8gOzdVDZlpyaB7fTRtWED8QcEMn/gL0yN3lPWF9Qg
         WlAuXPEnAfn2N84N0aHvTFEPYTyXuDmXbOGBlnFk3KhJD+cC7p8otA5MSdsj1RuAdtj2
         n9TYWOViHxNRl25j1LjqS3R0UasJ5kPwciWXhbzc3Bb+6ZhMYbgacnpcCRukwar1BFtr
         qcXgTn6puyH2Szhz8S41Kh7xbeqG3H4+GtrbTwtQrUhM0zWD/g1d+MeA78wGNGsd3hZC
         kgkl5B9IiDT+9nm+6yRWqrvN6kpioF/PrkF47RNROleGCMkvui3y768rooDlChhBzJsS
         4X3g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) smtp.mailfrom=logang@deltatee.com
X-Gm-Message-State: AJcUukdM8+DfP/8MIXnsDVOwQ9j3/50vHBtnNAMJkTGdrqYhyuXoBWDv
	4a8HJtgSgLyBL/atdTx3HSur5Uzu1hSecJfKoEhlN1MOPf1xd1Kec3RJduJgFh4bAZ5BNWHrCgu
	fZO7KbpicvL4XVDKI4XodQHNphQrfQHV7z3wMAlrIBTryR/PcSlggpHTRLE77AMzspw==
X-Received: by 2002:a6b:fb01:: with SMTP id h1mr19914419iog.185.1548877725791;
        Wed, 30 Jan 2019 11:48:45 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4aBdp6qLh9La43CZVWa7TWLLXKMRDeMqnbbWreLOa0375m28r4gEd16ZQN9ZH9bt5UmV5x
X-Received: by 2002:a6b:fb01:: with SMTP id h1mr19914392iog.185.1548877725220;
        Wed, 30 Jan 2019 11:48:45 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548877725; cv=none;
        d=google.com; s=arc-20160816;
        b=vmn3mrSbkkziaIez0amphE+7/rGKeG3q5jKWcJ1CfVorg3xvFvfS0rm/TrOz6AsnQ1
         IcjAYC2irZYyaQ533KMZhYxP5XCQaWfURCMtwTWk8EeuyYgb2LkMmx+8ZOClGS/ZMhu+
         hd2J9/g3O3BgImJv4XnMBnynM6LR8+ni9xBQk9P+FKhaRTwt34tiILziDIm3nIGTEs+A
         nKTZFG9uq8iIfQMVuokLyEU8bHTfTIP36Qyrosj1iZ+c1EtCw0uHdcrXS911/vPSMk4W
         cZDWvHuN1Ox3nBEGABFIJCifzHOBmk18BmfnyFR9VUBMIVyLvV5RYHGPTNwhq0iiSmuH
         UVkA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=subject:content-transfer-encoding:content-language:in-reply-to
         :mime-version:user-agent:date:message-id:from:references:cc:to;
        bh=R0XqkFHvjJbmr89hBrYpg4+Bb0t2c0TP+VUWudgcqs0=;
        b=ywQpbUKaVKgGxBQd4vAxrfjY8VgyO7bEtoTzNKquQFUd9jIViUNA99nF2btew+jloy
         HC88mxo5KpDy5xL+gqAersrwtiV9u/g+IndJRdMbmLrevn6afIkthWdyRbSS/YMKBCeP
         TrD6cjBH0EQjrgqKE2Bs6amr0b3eD2XnehVnsHyNJabpPa/bz2szmCDuNLt/n+WQlL7M
         yGrlPxXX6OOxlisS2jbe/Oidp/cuxHekEYbsLhlURAOjgro7oZQJg1R/TkZQj2ouFD53
         H++1+P+KEPMoSFSjKzJF8stI8cNJlcqjR88pnUSmH/2lHIcDyvKO7BSV56RG7S1JBpJW
         nd3Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) smtp.mailfrom=logang@deltatee.com
Received: from ale.deltatee.com (ale.deltatee.com. [207.54.116.67])
        by mx.google.com with ESMTPS id v12si1578396itb.53.2019.01.30.11.48.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 30 Jan 2019 11:48:45 -0800 (PST)
Received-SPF: pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) client-ip=207.54.116.67;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) smtp.mailfrom=logang@deltatee.com
Received: from s01061831bf6ec98c.cg.shawcable.net ([68.147.80.180] helo=[192.168.6.205])
	by ale.deltatee.com with esmtpsa (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128)
	(Exim 4.89)
	(envelope-from <logang@deltatee.com>)
	id 1govqd-0008Qp-Gb; Wed, 30 Jan 2019 12:48:36 -0700
To: Jason Gunthorpe <jgg@mellanox.com>
Cc: Christoph Hellwig <hch@lst.de>, Jerome Glisse <jglisse@redhat.com>,
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
References: <20190129174728.6430-1-jglisse@redhat.com>
 <20190129174728.6430-4-jglisse@redhat.com>
 <ae928aa5-a659-74d5-9734-15dfefafd3ea@deltatee.com>
 <20190129191120.GE3176@redhat.com> <20190129193250.GK10108@mellanox.com>
 <99c228c6-ef96-7594-cb43-78931966c75d@deltatee.com>
 <20190129205827.GM10108@mellanox.com> <20190130080208.GC29665@lst.de>
 <20190130174424.GA17080@mellanox.com>
 <bcbdfae6-cfc6-c34f-4ff2-7bb9a08f38af@deltatee.com>
 <20190130191946.GD17080@mellanox.com>
From: Logan Gunthorpe <logang@deltatee.com>
Message-ID: <3793c115-2451-1479-29a9-04bed2831e4b@deltatee.com>
Date: Wed, 30 Jan 2019 12:48:33 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190130191946.GD17080@mellanox.com>
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



On 2019-01-30 12:19 p.m., Jason Gunthorpe wrote:
> On Wed, Jan 30, 2019 at 11:13:11AM -0700, Logan Gunthorpe wrote:
>>
>>
>> On 2019-01-30 10:44 a.m., Jason Gunthorpe wrote:
>>> I don't see why a special case with a VMA is really that different.
>>
>> Well one *really* big difference is the VMA changes necessarily expose
>> specialized new functionality to userspace which has to be supported
>> forever and may be difficult to change. 
> 
> The only user change here is that more things will succeed when
> creating RDMA MRs (and vice versa to GPU). I don't think this
> restricts the kernel implementation at all, unless we intend to
> remove P2P entirely..

Well for MRs I'd expect you are using struct pages to track the memory
some how.... VMAs that aren't backed by pages and use this special
interface must therefore be creating new special interfaces that can
call p2p_[un]map...

I'd much rather see special cases around struct page so we can find ways
to generalize it in the future than create special cases tied to random
userspace interfaces.

Logan

