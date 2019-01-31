Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3F1B8C282D9
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 19:19:51 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 07585218EA
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 19:19:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 07585218EA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=deltatee.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9CD478E0004; Thu, 31 Jan 2019 14:19:50 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 955478E0001; Thu, 31 Jan 2019 14:19:50 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 81EA28E0004; Thu, 31 Jan 2019 14:19:50 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id 56EC28E0001
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 14:19:50 -0500 (EST)
Received: by mail-it1-f198.google.com with SMTP id g7so3370696itg.7
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 11:19:50 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding:subject;
        bh=5Vc8ZUnqjhO0zFhlxW2NETZ1/Nee5MEwnQEwZBj6gus=;
        b=U8pJmVYGy1w8zyGlcYST4m4C7peHTd9HAxe93Ip7uvoBZDbNCKcXTp7/0PML17nkX0
         L+mQg3Z6Xm2ZM3cFA1ucuQUeja1pP6C4bV6F8Nd/kOFX21x1YB0BSCsnSKebCXQvURUl
         wpCVE5AyOGlGalt2AVaSuraZHpQN1DCuxghnCA56ONLza6g0FN8ImONIYxMo+ieje2Yg
         D7e6m3w6GUQbz+qYOCvWIVcYYjB1qRWS/BAw/kpKjfCDMK/yUBFsTOcMqABE1uRVgM0s
         RTDwm8L0e528IRf5HQX4BAG9z6gXwd2SbeXr+pQxcyzRdvyHlaTcpZwnv5Fpuy1ytrX6
         0x8g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) smtp.mailfrom=logang@deltatee.com
X-Gm-Message-State: AJcUukd8uPZ+2A5uidgre15NlXCYkcHeOHoSbRx68hMveYGWe9PFY0jW
	FhUd7OmPYn1bXt/jEdTaH976C544pytlRrSeAK+J72pvYGjb4GuAqv7Zg2FGm0z1zLi+foiyolt
	6KdG2TiAyyTSJL/lSi/LJ9FmaktQE6+eLwKP5kRXDRG6m5hmNzmMmcI8mi87JLJkvCQ==
X-Received: by 2002:a24:4606:: with SMTP id j6mr16224902itb.10.1548962390126;
        Thu, 31 Jan 2019 11:19:50 -0800 (PST)
X-Google-Smtp-Source: ALg8bN6JmgHQ74x857kKHcCxNHI5wig+VWxCwUgsbqaNJ96TMrDQobW0W+vqTkJUEXdA2xAgpT/P
X-Received: by 2002:a24:4606:: with SMTP id j6mr16224873itb.10.1548962389208;
        Thu, 31 Jan 2019 11:19:49 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548962389; cv=none;
        d=google.com; s=arc-20160816;
        b=TzmTmBbhwrbjRpmaq8qYkF2DhIx6x7H0AeUCc3Nh4ILjkZzPf4bjwbLoqaaBcveqJW
         1TI7Wrbf4RHWEYQwf6uWz4TGAvxwy2JZ13GdS7MtTPbluqSbUbyLe8PP9WTLwTXTQOKi
         SBiAJOLiWgh3a9Bn15z3czO38Kj65MPsJoWq16ufqN5rBerAt1vHyM9yoy7DUSz6wuBN
         gLezTIaMIn1zBCNsi6PLQed+P9CY+ZFu0etL/4a4zn4TK4LtbIkk5AUkIVHpDDKAiNFR
         NfTPpa6ptzlJfxqrXW86T7G/uKT9tuNVbO/hKGfYHSbB8XANHrwhfTqvIty53D3Zn23G
         pRzQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=subject:content-transfer-encoding:content-language:in-reply-to
         :mime-version:user-agent:date:message-id:from:references:cc:to;
        bh=5Vc8ZUnqjhO0zFhlxW2NETZ1/Nee5MEwnQEwZBj6gus=;
        b=J3Mh445bWbf9AFu88TZlc+E0A6QsuYpzN6YzRcJiZ6YOD+xFjZLA6BpwBe1cn7gP6g
         oTJiZhETbCZeaujPGtFzEU1NQQfXbiXeO5/4IN9CM1ZLJHxfTprTIUthfPohlT4wPmS6
         7hmB/1378Hek0pnucpa1Hn8BYyd6cHMd5gt4vVWLJQAQcJ0wV3NrJHcC1yW9v2fK8CCT
         1BiN8+8/gxNuXtk+d9qexSSNxduGwGnKG2vStv9jldesDsBo2QrKOyJhnS7h0QwI8xqx
         wt2LyQkaWWtpx6ixjsrcoadF8dBgkuWlEQ87bTwRIx/S/monwj4v6PJcoOrSQOlBBXLD
         OKYQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) smtp.mailfrom=logang@deltatee.com
Received: from ale.deltatee.com (ale.deltatee.com. [207.54.116.67])
        by mx.google.com with ESMTPS id a124si3056451jaa.87.2019.01.31.11.19.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 31 Jan 2019 11:19:49 -0800 (PST)
Received-SPF: pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) client-ip=207.54.116.67;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) smtp.mailfrom=logang@deltatee.com
Received: from guinness.priv.deltatee.com ([172.16.1.162])
	by ale.deltatee.com with esmtp (Exim 4.89)
	(envelope-from <logang@deltatee.com>)
	id 1gpHsA-0002Rf-H6; Thu, 31 Jan 2019 12:19:39 -0700
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
References: <655a335c-ab91-d1fc-1ed3-b5f0d37c6226@deltatee.com>
 <20190130041841.GB30598@mellanox.com> <20190130080006.GB29665@lst.de>
 <20190130190651.GC17080@mellanox.com>
 <840256f8-0714-5d7d-e5f5-c96aec5c2c05@deltatee.com>
 <20190130195900.GG17080@mellanox.com>
 <35bad6d5-c06b-f2a3-08e6-2ed0197c8691@deltatee.com>
 <20190130215019.GL17080@mellanox.com>
 <07baf401-4d63-b830-57e1-5836a5149a0c@deltatee.com>
 <20190131081355.GC26495@lst.de> <20190131190202.GC7548@mellanox.com>
From: Logan Gunthorpe <logang@deltatee.com>
Message-ID: <e4fd743f-61cb-a443-bc53-9a1c036ebe8c@deltatee.com>
Date: Thu, 31 Jan 2019 12:19:31 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190131190202.GC7548@mellanox.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-CA
Content-Transfer-Encoding: 7bit
X-SA-Exim-Connect-IP: 172.16.1.162
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



On 2019-01-31 12:02 p.m., Jason Gunthorpe wrote:
> I still think the right direction is to build on what Logan has done -
> realize that he created a DMA-only SGL - make that a formal type of
> the kernel and provide the right set of APIs to work with this type,
> without being forced to expose struct page.

> Basically invert the API flow - the DMA map would be done close to
> GUP, not buried in the driver. This absolutely doesn't work for every
> flow we have, but it does enable the ones that people seem to care
> about when talking about P2P.
> It also does present a path to solve some cases of the O_DIRECT
> problems if the block stack can develop some way to know if an IO will
> go down a DMA-only IO path or not... This seems less challenging that
> auditing every SGL user for iomem safety??


The DMA-only SGL will work for some use cases, but I think it's going to
be a challenge for others. We care most about NVMe and, therefore, the
block layer.

Given my understanding of the block layer, and it's queuing
infrastructure, I don't think having a DMA-only IO path makes sense. I
think it has to be the same path, but with a special DMA-only bio; and
endpoints would have to indicate support for that bio. I can't say I
have a deep enough understanding of the block layer to know how possible
that would be.

Logan

