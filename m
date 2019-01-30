Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 443A0C282D7
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 20:43:39 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E6EB4218AC
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 20:43:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E6EB4218AC
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 92D0A8E0003; Wed, 30 Jan 2019 15:43:38 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8DD368E0001; Wed, 30 Jan 2019 15:43:38 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7A5778E0003; Wed, 30 Jan 2019 15:43:38 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 521B98E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 15:43:38 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id w28so848038qkj.22
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 12:43:38 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=/KQuiK7VXznvDCndBNBdfJA6yVh7Zl2LT8h4OPx3En0=;
        b=EOciPLlfMdxgvSnr6fjzUXCdFnmP10hWWVt5dl8LfKtZ5L/W5X2MXL8oTxrQyD2tV7
         FGEGXGS6K3zzsCe5i2mJ4OHNvkLefuk+bLLnFE6BjPTIwIvvnKPrNc4wJzp3qeObjNU1
         0WBThp8dPjAIPEbSDJSCtSG+gGfrD7GEKJUwyHd96yRl6nDr8urXUjO+W8PdsGMQeIfX
         EZFkb3TuxjspAGfUEfCl3i6Hajtm8gvd/93vlK9GHEw6KbtRdTh0/XLBkZw0jj19GcnW
         sCpOzEzPsZgcTx4mtY3fAQ6ugNyRTNKERtePDuGzq92zvyKSbsMjQEs8dAzzP2PLmV12
         nmmA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AJcUukdu38bO4Dz68rwNoowFBySo4wlxaowlHpi1yzYIK7k3KNK3R2N9
	8oVtOku8mobqgfz8u+4zvxFjEpxduuySu+LwVNkZCqduM2hv0r56tI/TJUhWR3WN25untgxbwQS
	zL0BsthGEwowHJWkMA+ER1lBzIExeG7o1Jk8D7nygaPN1FqyeshHoHtNGYv0hNNHK7g==
X-Received: by 2002:ac8:2c79:: with SMTP id e54mr31714598qta.17.1548881018050;
        Wed, 30 Jan 2019 12:43:38 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4UjhwHib/kpp/ME57hLEDBTU47yH5OyK2L5FC6uivuoCnEmABUsAN9b+3XXC0pHIhzMEdr
X-Received: by 2002:ac8:2c79:: with SMTP id e54mr31714563qta.17.1548881017343;
        Wed, 30 Jan 2019 12:43:37 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548881017; cv=none;
        d=google.com; s=arc-20160816;
        b=euXVoVDUKMRyoLLDjeeTRUA3krvWywL195BGphT/chl/f1L4QIau0EdO+im5VLhP1K
         ntrXuVp3m6xP5XPJaLXifln9H16w5Xuw13uGTCn/2u+2vFsuhjTdDT9/NQsAgQPGwgWz
         r1L7x6kDzjW89qIK8wbsj1DSjUfMgI1Go6GNfRE93xJbHl5gT6xznOwDTzqmNi5Ybl1C
         iWQWpmVfe3e8tzLfIxA/jkLzqATkiLWQxxDKOKlvXBZ4ntQtTe2nzqfhibQkkYDZ+TaM
         1Dn4lULE2eeBM5xMyf1+cCvCxOkKgPQP3LDAfYgctv6IQMMD+dPEqFYrmiytd5AMnBsP
         /Owg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=/KQuiK7VXznvDCndBNBdfJA6yVh7Zl2LT8h4OPx3En0=;
        b=lh9rLR/CLEOm+QNXVQa4wc96nP9xNnZgXlTEoJvnlNB/Lxpzpbsw7uDqNlaFmNiDxU
         2SxHiXqkLT9o2m8DmGj+8faIszcYif9PjWyvjwSZcMQoJoQhUJewrwPauPs25cJlI7SF
         XJ9Uwljxi2+0VpDWbyXXzTh3Q/wul4BtiiHbkoV+WZWlh4cR+ieUvrfjOfPfTkDB1Ti+
         cpiOkxUBHsLTL9W0iThAosA9NnM9nj9LOY5fRuBsBD2a3MzLlIwTt7wDwJwsNUi/jGyr
         SutyGd5NdfyF3d/xS5auJMrCEy1oH4OUzS13M57oVPgYsMjUC+t2YXUv38idOkPxGLt2
         Ftew==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n64si378038qtd.105.2019.01.30.12.43.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Jan 2019 12:43:37 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 3AD2A356D3;
	Wed, 30 Jan 2019 20:43:36 +0000 (UTC)
Received: from redhat.com (ovpn-126-0.rdu2.redhat.com [10.10.126.0])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 33B68103BAB8;
	Wed, 30 Jan 2019 20:43:34 +0000 (UTC)
Date: Wed, 30 Jan 2019 15:43:32 -0500
From: Jerome Glisse <jglisse@redhat.com>
To: Jason Gunthorpe <jgg@mellanox.com>
Cc: Logan Gunthorpe <logang@deltatee.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Rafael J . Wysocki" <rafael@kernel.org>,
	Bjorn Helgaas <bhelgaas@google.com>,
	Christian Koenig <christian.koenig@amd.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	Christoph Hellwig <hch@lst.de>,
	Marek Szyprowski <m.szyprowski@samsung.com>,
	Robin Murphy <robin.murphy@arm.com>, Joerg Roedel <jroedel@suse.de>,
	"iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>
Subject: Re: [RFC PATCH 3/5] mm/vma: add support for peer to peer to device
 vma
Message-ID: <20190130204332.GF5061@redhat.com>
References: <deb7ba21-77f8-0513-2524-ee40a8ee35d5@deltatee.com>
 <20190129234752.GR3176@redhat.com>
 <655a335c-ab91-d1fc-1ed3-b5f0d37c6226@deltatee.com>
 <20190130041841.GB30598@mellanox.com>
 <bdf03cd5-f5b1-4b78-a40e-b24024ca8c9f@deltatee.com>
 <20190130185652.GB17080@mellanox.com>
 <20190130192234.GD5061@redhat.com>
 <20190130193759.GE17080@mellanox.com>
 <db873687-ff80-4758-0b9f-973f27db5335@deltatee.com>
 <20190130201114.GB17915@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190130201114.GB17915@mellanox.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.30]); Wed, 30 Jan 2019 20:43:36 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jan 30, 2019 at 08:11:19PM +0000, Jason Gunthorpe wrote:
> On Wed, Jan 30, 2019 at 01:00:02PM -0700, Logan Gunthorpe wrote:
> 
> > We never changed SGLs. We still use them to pass p2pdma pages, only we
> > need to be a bit careful where we send the entire SGL. I see no reason
> > why we can't continue to be careful once their in userspace if there's
> > something in GUP to deny them.
> > 
> > It would be nice to have heterogeneous SGLs and it is something we
> > should work toward but in practice they aren't really necessary at the
> > moment.
> 
> RDMA generally cannot cope well with an API that requires homogeneous
> SGLs.. User space can construct complex MRs (particularly with the
> proposed SGL MR flow) and we must marshal that into a single SGL or
> the drivers fall apart.
> 
> Jerome explained that GPU is worse, a single VMA may have a random mix
> of CPU or device pages..
> 
> This is a pretty big blocker that would have to somehow be fixed.

Note that HMM takes care of that RDMA ODP with my ODP to HMM patch,
so what you get for an ODP umem is just a list of dma address you
can program your device to. The aim is to avoid the driver to care
about that. The access policy when the UMEM object is created by
userspace through verbs API should however ascertain that for mmap
of device file it is only creating a UMEM that is fully covered by
one and only one vma. GPU device driver will have one vma per logical
GPU object. I expect other kind of device do that same so that they
can match a vma to a unique object in their driver.

> 
> > That doesn't even necessarily need to be the case. For HMM, I
> > understand, struct pages may not point to any accessible memory and the
> > memory that backs it (or not) may change over the life time of it. So
> > they don't have to be strictly tied to BARs addresses. p2pdma pages are
> > strictly tied to BAR addresses though.
> 
> No idea, but at least for this case I don't think we need magic HMM
> pages to make simple VMA ops p2p_map/umap work..

Yes, you do not need page for simple driver, if we start creating struct
page for all PCIE BAR we are gonna waste a lot of memory and resources
for no good reason. I doubt all of the PCIE BAR of a device enabling p2p
will ever be map as p2p. So simple driver do not need struct page, GPU
driver that do not use HMM (all GPU that are more than 2 years old) do
not need struct page. Struct page is a burden here more than anything
else. I have not seen one good thing the struct page gives you.

Cheers,
Jérôme

