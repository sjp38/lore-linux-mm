Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E0A7FC282D8
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 18:13:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ADA8621473
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 18:13:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ADA8621473
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=deltatee.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3FDC28E0005; Wed, 30 Jan 2019 13:13:27 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3AD518E0001; Wed, 30 Jan 2019 13:13:27 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 276E28E0005; Wed, 30 Jan 2019 13:13:27 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id F23278E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 13:13:26 -0500 (EST)
Received: by mail-io1-f70.google.com with SMTP id a2so315539ioq.9
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 10:13:26 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding:subject;
        bh=tbPMNGt3rbr9kB68jl16lEBm3Q+tLFUQ270bqirHpk0=;
        b=LDT4iFcmMqMfJrW3pYkLXiAiM1G7fXaFNpbvHQw5s0kGx6OpQnMXr5xPDKNOnjyXrv
         Gt1XygYBThZif6gluO+j4EYZnAdEzBthN6OfO47l6raF6aUAR5GQIBENe/ZHJSk1u9BT
         YFScN/Culzi9PbWMfwxXZfryLdQYFbiLYPj6mTPTdTtaczHph5tMy4rCHgWpriYR5Ef/
         qa7kBFxTbH4I7GyHXhyzbXy0jlO8z9JT5St1VRfRM/fGdl51Sw/qq3tdKiZZHFQvWEaY
         QK9VygPGXqAXuNOs+4+FY29p8EmV/+GFWgokQwUvWUzVSLKVG9iffRUxdNYDZMiSBi+x
         s8vA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) smtp.mailfrom=logang@deltatee.com
X-Gm-Message-State: AHQUAuYlv0wtU9QXN/pm7rAcLg14xAMnEKlh2TW3qjeVzlDhYg0ZqB2s
	1vBjiA5k3ZHhc/j51os4aKCoI8PNP0a8Gr+USIHpMXEo4KMhsJKsbQP1ftN7usFCKGHY6T7ky/z
	glppeJqdSNHfY8VcNx5wQm9M9FkMvTUaiULDttGgzYwkH3cW4SXCOj5QDLOB7sl5U6w==
X-Received: by 2002:a5d:8541:: with SMTP id b1mr18525221ios.214.1548872006772;
        Wed, 30 Jan 2019 10:13:26 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4VwMi+OJBC6/DmSQBD9bwndJa0ADLWFNKMy9lzYnM2u6ZU552vge2EcbGSb+/XOii4aEob
X-Received: by 2002:a5d:8541:: with SMTP id b1mr18525199ios.214.1548872006177;
        Wed, 30 Jan 2019 10:13:26 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548872006; cv=none;
        d=google.com; s=arc-20160816;
        b=gYuaVmF4f57XH1581mrfEv5EReaP182OSQHpKxOPKLPevmSFBhV1o/+itLjhVxv06W
         toGqv0H8IMmO2RMPmyCnQvuMp7AJCheYYSE4Xc8vbwlDCF6Y6lG8DFe+STGmMVY2kGBY
         BFECXetMzhGwSI+MgMLdoYNLhDIfF1S6kiAJyzd+x4aXY3btOhiJ4v4dRrHGz18YwYVA
         EI6s6ZGbbTCzuHKwMdYtch1HOfku7Sao2WKnaCN2/sDqqYPCqnmhM55JlGsa5R5gHXNn
         NJAjeA5XpMJQ1II6mylQDWfT670moWSoyXQVU6MSNGerpvZJuXbtHSVGCw0v3bLI6O9U
         QpGw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=subject:content-transfer-encoding:content-language:in-reply-to
         :mime-version:user-agent:date:message-id:from:references:cc:to;
        bh=tbPMNGt3rbr9kB68jl16lEBm3Q+tLFUQ270bqirHpk0=;
        b=YJGKZCL3VvL5/XlOiP4VIDyiT6bJtg6wItwjiqzxfG9e0ifqUkLm9kFWNtSJn94I8z
         RGJC34GEUE2gCJHJNnJv9bOSZ7SAke0JxYqEPpg93jR0cbKWru3S6gJ+2d83j2FSwW9s
         xonlks4OPpJAhIohMSehsBmTTlIQBRWxYcNhN87I0bvMzjABa+1uJiOL98t/eJ6h8Fwf
         z621WtG0mDtS2AunpcpmG8CyyeL2QDvr84DDEIeeGeoobQl0QK075eZNLRcyPnJyfmnL
         nmUXOAYqEy2+MrwWCKImVD2eqXV3QQIXpOsp5re0LGlg/Rzvb4E+hOZfD5S6H8b40+Kj
         1qwQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) smtp.mailfrom=logang@deltatee.com
Received: from ale.deltatee.com (ale.deltatee.com. [207.54.116.67])
        by mx.google.com with ESMTPS id j15si1524099itk.24.2019.01.30.10.13.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 30 Jan 2019 10:13:26 -0800 (PST)
Received-SPF: pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) client-ip=207.54.116.67;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) smtp.mailfrom=logang@deltatee.com
Received: from s01061831bf6ec98c.cg.shawcable.net ([68.147.80.180] helo=[192.168.6.205])
	by ale.deltatee.com with esmtpsa (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128)
	(Exim 4.89)
	(envelope-from <logang@deltatee.com>)
	id 1gouMO-0007KC-FJ; Wed, 30 Jan 2019 11:13:17 -0700
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
References: <20190129174728.6430-1-jglisse@redhat.com>
 <20190129174728.6430-4-jglisse@redhat.com>
 <ae928aa5-a659-74d5-9734-15dfefafd3ea@deltatee.com>
 <20190129191120.GE3176@redhat.com> <20190129193250.GK10108@mellanox.com>
 <99c228c6-ef96-7594-cb43-78931966c75d@deltatee.com>
 <20190129205827.GM10108@mellanox.com> <20190130080208.GC29665@lst.de>
 <20190130174424.GA17080@mellanox.com>
From: Logan Gunthorpe <logang@deltatee.com>
Message-ID: <bcbdfae6-cfc6-c34f-4ff2-7bb9a08f38af@deltatee.com>
Date: Wed, 30 Jan 2019 11:13:11 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190130174424.GA17080@mellanox.com>
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



On 2019-01-30 10:44 a.m., Jason Gunthorpe wrote:
> I don't see why a special case with a VMA is really that different.

Well one *really* big difference is the VMA changes necessarily expose
specialized new functionality to userspace which has to be supported
forever and may be difficult to change. The p2pdma code is largely
in-kernel and we can rework and change the interfaces all we want as we
improve our struct page infrastructure.

I'd also argue that p2pdma isn't nearly as specialized as this VMA thing
and can be used pretty generically to do other things. Though, the other
ideas we've talked about doing are pretty far off and may have other
challenges.

Logan

