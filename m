Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 71F6FC282D7
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 22:52:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 17EF1218D2
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 22:52:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 17EF1218D2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=deltatee.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CC2418E0004; Wed, 30 Jan 2019 17:52:29 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C71B48E0001; Wed, 30 Jan 2019 17:52:29 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B61998E0004; Wed, 30 Jan 2019 17:52:29 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 878058E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 17:52:29 -0500 (EST)
Received: by mail-io1-f71.google.com with SMTP id o22so1003854iob.13
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 14:52:29 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding:subject;
        bh=EdS938obF7AVtYIhYr5Ib63FEKUYdH54X0t0n3VoYKI=;
        b=T6ThPRGfHE6F30Y6BDTUIHjJqoKj7/E4A3rfYgO6Sfde8ZCigTP/Li5u6wgwfpPgO4
         8LPIDrxUK7NHTTrbnvtAlbPaDi9Z+6CnXvkax6Ql+7Ca+c2WR8L1XfIoYKq+rchye6BN
         hxsH0WOhDisxYN7X+9gda7kFVneFBN+TTCiwk45QjaJKOnPtRWyUzS6JOPT1kZTpBLtw
         w5C+HXd7QisEq0DMXOeklJTA1IGY9YOgnumcbOoVu/bDaHjrKt9iQ1Vz4Sviy8zg19yU
         KyUzZhFZvjndMqcWT/wj58ByIorMtYKZTvfuvc5FQivFvVxeKC3dVDkkODQ4WGzle5zb
         rjrw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) smtp.mailfrom=logang@deltatee.com
X-Gm-Message-State: AHQUAuZ2LYjpH9B5MCX8vF2OntKOM9UParN+wd+M6r3ZZX/gCjYlprKo
	Kp3OQ2lrpQ9kYiG/g+knb9CKjerSjREBEIHcSF/wZQ5pzYYb1sDkgnu2G6lUKYju5KVXcp0BcGU
	8ek/TZvYKOIqTvlGKLUBinY3HSMz/c0m//sh3D0U5a3bG9XEAXAyqWY514T17gh2PyA==
X-Received: by 2002:a5e:df0d:: with SMTP id f13mr11997299ioq.153.1548888749293;
        Wed, 30 Jan 2019 14:52:29 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYypgtNrH+8xu8ykTn58A3qLo1XU4Nuj8rTE/cg3/KPurRiLH3VgVxhm/3tIE36Waz6t6uJ
X-Received: by 2002:a5e:df0d:: with SMTP id f13mr11997274ioq.153.1548888748644;
        Wed, 30 Jan 2019 14:52:28 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548888748; cv=none;
        d=google.com; s=arc-20160816;
        b=xNsv1RUnFd9dsobd0kJFRR2/1nC0G+kYxiwwhH8ByGQq0AuhNBqgiKl8a64VZfdYiY
         FrkrTH+2kqWnMxH80d4BOViV+VUZElMUPuj4YjWtwZf/wWj4y4EwRVrXq4WFSHIrHnwq
         n4f23p7qEwdrMMl9l1OoEybRlVrje3+GCosqL8TxC1agosOg4O7NMicWGZS6qs+BHh++
         RCt3mZFH+v5NcGc9ZL00c417coZO6bj4rw6D4XSl7LYR2KeqdaDo1faKivtzeFQokZ2l
         1DPNCprdO/f0V/kaFl5xQ3ZxjAWHsD3x/foX28VaVKBhGtX7bs3Doixj/mwR0V1rnSxD
         y5kA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=subject:content-transfer-encoding:content-language:in-reply-to
         :mime-version:user-agent:date:message-id:from:references:cc:to;
        bh=EdS938obF7AVtYIhYr5Ib63FEKUYdH54X0t0n3VoYKI=;
        b=qfD4T0egx38zYpXVGqqZqfpS37nBVeXlauj2ncyjqISG7iQkUqhvQ3Xnmcjxj0aw2u
         9Fj0H5suDpe6s6CuPuc3CdeZlhHmthIBfLyDB3AgmbE/ogL9mevcYF9tPSBf7jQqskkR
         taQUoL2jKxPrRr8z/GOKxWQzQe1P+jtEz2SSeI5RP9u5fi4N6BOkuaR6VDi3/f/X5Msg
         B+aVJTacieqZ0Ej1w8oGu9SHnDR06Njb0OLQTJwKyl2zq41gLknW9RsVBGewg4DKu7k1
         U0P0wK5zqfYFUOF21s000hBrInNIHDrOyxJa1EkDGzTk2nbikUy8MgOykAYr7uwOVG+3
         fn1w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) smtp.mailfrom=logang@deltatee.com
Received: from ale.deltatee.com (ale.deltatee.com. [207.54.116.67])
        by mx.google.com with ESMTPS id 187si1976065itl.18.2019.01.30.14.52.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 30 Jan 2019 14:52:28 -0800 (PST)
Received-SPF: pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) client-ip=207.54.116.67;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of logang@deltatee.com designates 207.54.116.67 as permitted sender) smtp.mailfrom=logang@deltatee.com
Received: from s01061831bf6ec98c.cg.shawcable.net ([68.147.80.180] helo=[192.168.6.205])
	by ale.deltatee.com with esmtpsa (TLS1.2:ECDHE_RSA_AES_128_GCM_SHA256:128)
	(Exim 4.89)
	(envelope-from <logang@deltatee.com>)
	id 1goyiP-0002Sm-FK; Wed, 30 Jan 2019 15:52:18 -0700
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
References: <20190129215028.GQ3176@redhat.com>
 <deb7ba21-77f8-0513-2524-ee40a8ee35d5@deltatee.com>
 <20190129234752.GR3176@redhat.com>
 <655a335c-ab91-d1fc-1ed3-b5f0d37c6226@deltatee.com>
 <20190130041841.GB30598@mellanox.com> <20190130080006.GB29665@lst.de>
 <20190130190651.GC17080@mellanox.com>
 <840256f8-0714-5d7d-e5f5-c96aec5c2c05@deltatee.com>
 <20190130195900.GG17080@mellanox.com>
 <35bad6d5-c06b-f2a3-08e6-2ed0197c8691@deltatee.com>
 <20190130215019.GL17080@mellanox.com>
From: Logan Gunthorpe <logang@deltatee.com>
Message-ID: <07baf401-4d63-b830-57e1-5836a5149a0c@deltatee.com>
Date: Wed, 30 Jan 2019 15:52:13 -0700
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190130215019.GL17080@mellanox.com>
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



On 2019-01-30 2:50 p.m., Jason Gunthorpe wrote:
> On Wed, Jan 30, 2019 at 02:01:35PM -0700, Logan Gunthorpe wrote:
> 
>> And I feel the GUP->SGL->DMA flow should still be what we are aiming
>> for. Even if we need a special GUP for special pages, and a special DMA
>> map; and the SGL still has to be homogenous....
> 
> *shrug* so what if the special GUP called a VMA op instead of
> traversing the VMA PTEs today? Why does it really matter? It could
> easily change to a struct page flow tomorrow..

Well it's so that it's composable. We want the SGL->DMA side to work for
APIs from kernel space and not have to run a completely different flow
for kernel drivers than from userspace memory.

For GUP to do a special VMA traversal it would now need to return
something besides struct pages which means no SGL and it means a
completely different DMA mapping call.
> Would you feel better if this also came along with a:
> 
>   struct dma_sg_table *sgl_dma_map_user(struct device *dma_device, 
>              void __user *prt, size_t len)

That seems like a nice API. But certainly the implementation would need
to use existing dma_map or pci_p2pdma_map calls, or whatever as part of
it...

,
> flow which returns a *DMA MAPPED* sgl that does not have struct page
> pointers as another interface?
> 
> We can certainly call an API like this from RDMA for non-ODP MRs.
> 
> Eliminating the page pointers also eliminates the __iomem
> problem. However this sgl object is not copyable or accessible from
> the CPU, so the caller must be sure it doesn't need CPU access when
> using this API. 

We actually stopped caring about the __iomem problem. We are working
under the assumption that pages returned by devm_memremap_pages() can be
accessed as normal RAM and does not need the __iomem designation. The
main problem now is that code paths need to know to use pci_p2pdma_map
or not. And in theory this could be pushed into regular dma_map
implementations but we'd have to get it into all of them which is a pain.

Logan

