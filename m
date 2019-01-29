Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 28AFDC282D0
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 20:43:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E296B2087E
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 20:43:16 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E296B2087E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=deltatee.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 811F28E0002; Tue, 29 Jan 2019 15:43:16 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7E8A78E0001; Tue, 29 Jan 2019 15:43:16 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 687778E0002; Tue, 29 Jan 2019 15:43:16 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3DF8A8E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 15:43:16 -0500 (EST)
Received: by mail-io1-f71.google.com with SMTP id p4so17517617iod.17
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 12:43:16 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding:subject;
        bh=jrLa0heztJxd+phigMieY7ipFQTWaiJi0+Huo35BWqM=;
        b=BjpXI5kxCrshx0x7LNATo13dDoCegzhGDuTCIugR9zG+h2Gepw8HUxoedsfJ2A50Xd
         igA/9bdDs4tlXDtFEbPegxVRmnmk/rUm0QOpwKtWwHOcQzR1mDxbvF5htmPB7W/y3b3Z
         jHvQaxwRKsaWmQLVXezKf3LugrBhrPutKug2ltD315j57X75P+QyLLWLiGCENEZYTMn2
         EcIm/rdedXtXTNc4X0A4AT+dpE7m4UXvuj3qnmDmJyryS3CdLlaXTj2XqmrzUqPXfydd
         PVAroSKLTmSi2lhmciqjLUJXwOoBX552ucbmZXkn5u1dqxOeXXF4NEebD33w0B6Qdhiu
         2DjQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) smtp.mailfrom=logang@deltatee.com
X-Gm-Message-State: AHQUAuZ9KzuvNFgltGxKnXV5OF5zYttuCkoRGl7unUvdFVb6J+ROfy83
	dfEhvNZT7OThal8de/OGdVJ/xw54DYcuK1+WdPGw93HPKeSFV/gzn/jUA7fy/EKmZfQF7sgseNa
	3a8foy8OpCfPPuNyQ9YB0wpqe3XrIDxhGs8qT3nlTXDdwubwUISRrJESMU54rIXu3Lg==
X-Received: by 2002:a24:20e:: with SMTP id 14mr14749169itu.170.1548794596048;
        Tue, 29 Jan 2019 12:43:16 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4HNw+0YLMgZfIoFhfgT6n6jalCWXc7VDrz+y5l/0ODuOxHRUXgqhCdxIQdG832qOqXjOe8
X-Received: by 2002:a24:20e:: with SMTP id 14mr14749158itu.170.1548794595536;
        Tue, 29 Jan 2019 12:43:15 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548794595; cv=none;
        d=google.com; s=arc-20160816;
        b=emZ08bQDdTiN9RRr3A/7GZdu22hbcQR87wkVUt4L63xv3Dm1XEPk6rOcGKFiMZAnSK
         quXcNEEbdNfJkzF661ITS9ixN7Pfs1iqSXHmfc0mnpKlanWQdTMsCv4k/5enDpbOxzAw
         CxjjtklfNN6NW5PQ1arZVRxB/1eBY5IcJTXC3YCvWAua1i14HG2rghdsIwstg+Y+1Wgg
         /od33d4AU0xzETiEZ9EM7x8966X2GNokqL7PgvqpPVO+l8/hgocyIfjAN/3hHwKuUIsL
         YZ16XIDQwPjDxn5ohP/ZPvXvbuA6u6/MJUVN3F/IgapybEYMNIYxjNk9xiWBelDIppFk
         FZ7g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=subject:content-transfer-encoding:content-language:in-reply-to
         :mime-version:user-agent:date:message-id:from:references:cc:to;
        bh=jrLa0heztJxd+phigMieY7ipFQTWaiJi0+Huo35BWqM=;
        b=QD0reNkszqe9pOYy8hK9pPD6vW8pAy9sYKtrFDxzAt74TMUx1y6Re+Za2srSxGAYZj
         RYJTQuNuZOZRCGVXPKp6KdcoLqLLhDw3lxCmLrBmktnIIL636Zx04RW/0B4rfyUyLZOY
         p7Y5iz3W/fB77dwuwGBVwFzSJzgEVsa27Ofepvjv7FthHKE0Ems1QqrZb9CgsiGSrPIJ
         ZaGz2wgb4HxqAVhssdtgVIyCfOAJusdIUIYpUn3mP27UV9fuRP6HwCOf1UC07/5w2eac
         TtR0/zDDc4vpMl9TOpGVw5dvyQpRSRQXTJYzqS653TVdbgi9Dwdj/R1EFmt9xC99EG3s
         P78g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) smtp.mailfrom=logang@deltatee.com
Received: from ale.deltatee.com (ale.deltatee.com. [207.54.116.67])
        by mx.google.com with ESMTPS id m28si2583869jal.16.2019.01.29.12.43.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 29 Jan 2019 12:43:15 -0800 (PST)
Received-SPF: pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) client-ip=207.54.116.67;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) smtp.mailfrom=logang@deltatee.com
Received: from guinness.priv.deltatee.com ([172.16.1.162])
	by ale.deltatee.com with esmtp (Exim 4.89)
	(envelope-from <logang@deltatee.com>)
	id 1goaDn-0006jl-FD; Tue, 29 Jan 2019 13:43:04 -0700
To: Jerome Glisse <jglisse@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
 Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
 "Rafael J . Wysocki" <rafael@kernel.org>, Bjorn Helgaas
 <bhelgaas@google.com>, Christian Koenig <christian.koenig@amd.com>,
 Felix Kuehling <Felix.Kuehling@amd.com>, Jason Gunthorpe <jgg@mellanox.com>,
 linux-pci@vger.kernel.org, dri-devel@lists.freedesktop.org,
 Christoph Hellwig <hch@lst.de>, Marek Szyprowski <m.szyprowski@samsung.com>,
 Robin Murphy <robin.murphy@arm.com>, Joerg Roedel <jroedel@suse.de>,
 iommu@lists.linux-foundation.org
References: <20190129174728.6430-1-jglisse@redhat.com>
 <20190129174728.6430-4-jglisse@redhat.com>
 <ae928aa5-a659-74d5-9734-15dfefafd3ea@deltatee.com>
 <20190129191120.GE3176@redhat.com>
 <c2c02af7-1d6f-e54f-c7fb-99c5b7776014@deltatee.com>
 <20190129194418.GG3176@redhat.com>
From: Logan Gunthorpe <logang@deltatee.com>
Message-ID: <b3264844-2c04-6c34-f1e7-6b3bf9849a75@deltatee.com>
Date: Tue, 29 Jan 2019 13:43:02 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190129194418.GG3176@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-CA
Content-Transfer-Encoding: 7bit
X-SA-Exim-Connect-IP: 172.16.1.162
X-SA-Exim-Rcpt-To: iommu@lists.linux-foundation.org, jroedel@suse.de, robin.murphy@arm.com, m.szyprowski@samsung.com, hch@lst.de, dri-devel@lists.freedesktop.org, linux-pci@vger.kernel.org, jgg@mellanox.com, Felix.Kuehling@amd.com, christian.koenig@amd.com, bhelgaas@google.com, rafael@kernel.org, gregkh@linuxfoundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jglisse@redhat.com
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



On 2019-01-29 12:44 p.m., Jerome Glisse wrote:
>> I'd suggest [1] should be a part of the patchset so we can actually see
>> a user of the stuff you're adding.
> 
> I did not wanted to clutter patchset with device driver specific usage
> of this. As the API can be reason about in abstract way.

It's hard to reason about an interface when you can't see what all the
layers want to do with it. Most maintainers (I'd hope) would certainly
never merge code that has no callers, and for much the same reason, I'd
rather not review patches that don't have real use case examples.

Logan

