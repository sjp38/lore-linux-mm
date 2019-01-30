Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 181B6C3E8A4
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 15:55:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D7411218A3
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 15:55:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D7411218A3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 747758E0007; Wed, 30 Jan 2019 10:55:49 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6F7FC8E0001; Wed, 30 Jan 2019 10:55:49 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5C01C8E0007; Wed, 30 Jan 2019 10:55:49 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 305738E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 10:55:49 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id z126so6453qka.10
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 07:55:49 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=gRiQz7k6O+nvE7vjqvomxUiXlyS0rKvbbEhLd5cyc60=;
        b=NiHA86xmBlrxz8rTTOy77xPAz9CBvsuDSuc6iTCzRftGMXt1+99Bs5khjao22n2kEd
         +jOBMAWeVQdIe6ODQjiZfaYAIAXP2NcaCP7tXZ47w/KSb1wNGLp3T4/18ArHhiD67f35
         6Fnv2QUsxUsuvaY40769xAy4F4+Tkri0MrHigN6i9OFgtOg045V/q53xPTqTt9jkYy5J
         m47hl1M52XaySFvNQinH5Jz93ucw+4ZbFJ7DCN/7F60SucyOsd1Vc+bcFgiOfkN37vIw
         MoCeU4a5X7Dqx48PUwqfQViNR7YnuaNuzAfqLuwuePy/BiAaBy3eeMYIPLSR6GlLZ14R
         JFPQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AJcUukem+UW0xBc2bPfyb6hmXWPdY6os624LNkTVas4nTwFTuxdmcWQ0
	OS1V+n4nBB6mEaRJ/kEMSZWfYlUPr6ikfCQvvalR7deDG6hHjsXykv3tYsQedAk607Gaw2kcHKC
	Wz8lA+N+JWamtKXfjbb1pNnfyGNz/dsB0j1O9kpjKpyCUeLNsLA8C3ol12Oe/o0ICgA==
X-Received: by 2002:ac8:3914:: with SMTP id s20mr30800785qtb.294.1548863748928;
        Wed, 30 Jan 2019 07:55:48 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4z+HrE4REX3/te4CQ56sxvnmhlFQLPK9ahPw2o7Z8u19OVUSfwkDqbiI59/uUSnTkgG3++
X-Received: by 2002:ac8:3914:: with SMTP id s20mr30800755qtb.294.1548863748345;
        Wed, 30 Jan 2019 07:55:48 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548863748; cv=none;
        d=google.com; s=arc-20160816;
        b=gM/cXuCN6kV1QNvFSqOJRW1nMFNgCsL6jQ6aUD/NcRGBKXkjFVDxdbN86gMEVFMjcK
         DKTQLuNckKfpFWyRDvmveLaP2YGeX2tfDKhKuzYbuiC94BiSbjryIpcFkWiLyF1Zl3Ma
         Q28vzBj4psKBYBgPyxXybrk+g/vBOafFC4wXhKa6FFTNdLcCIiZdHyYnwwk7ObiGDBCF
         ZrEGfNlGI+nrgIOKvwSonHvG6dWLeRspwFH5qgiiy8fdVBznOKhrlS/dhyiif/qA1oes
         5jxGDJo7nBoOESsMGPhNJRAfWM3TvlR/oQqz10Y7m8bk69Crsc1xQ9WJwJ0kxqQgEvdo
         wU4Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=gRiQz7k6O+nvE7vjqvomxUiXlyS0rKvbbEhLd5cyc60=;
        b=ucCp6PXLc9y/O+I1LPMIlFXXA966R12ZKi09SleNsisgU9hdzj9AskF7BrTXjeftzy
         IOU9g1PPauCqKqnSb/hVcHoqNaNm7qYp17k7+BiqqjulLI95xXNhksX6iCjcQ7ow3EIz
         mgTMpw6PDvpye6FbQT8LW4tzgCf+5UImqzGJo+qA07K4/ZuIWiWqwqoPdRi/l9znF6YI
         NOz77WDyoDDX+0HP2zSWY6BsRPaYzT31ziwce8saIdbUDRjY1H55SnEC4q40l3nVv86O
         vPq+O4wFkeBGD0Tv8M8DrT8YYwvTzhYiLkPH5N4p8pGi7VoLunzu9QsdqodsI4Ft9a8E
         icnQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c18si1260849qvb.181.2019.01.30.07.55.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Jan 2019 07:55:48 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 08E098762E;
	Wed, 30 Jan 2019 15:55:47 +0000 (UTC)
Received: from redhat.com (ovpn-126-0.rdu2.redhat.com [10.10.126.0])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 41DB25C21E;
	Wed, 30 Jan 2019 15:55:45 +0000 (UTC)
Date: Wed, 30 Jan 2019 10:55:43 -0500
From: Jerome Glisse <jglisse@redhat.com>
To: "Koenig, Christian" <Christian.Koenig@amd.com>
Cc: Christoph Hellwig <hch@lst.de>, Jason Gunthorpe <jgg@mellanox.com>,
	Logan Gunthorpe <logang@deltatee.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Rafael J . Wysocki" <rafael@kernel.org>,
	Bjorn Helgaas <bhelgaas@google.com>,
	"Kuehling, Felix" <Felix.Kuehling@amd.com>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	Marek Szyprowski <m.szyprowski@samsung.com>,
	Robin Murphy <robin.murphy@arm.com>, Joerg Roedel <jroedel@suse.de>,
	"iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>
Subject: Re: [RFC PATCH 3/5] mm/vma: add support for peer to peer to device
 vma
Message-ID: <20190130155543.GC3177@redhat.com>
References: <20190129174728.6430-1-jglisse@redhat.com>
 <20190129174728.6430-4-jglisse@redhat.com>
 <ae928aa5-a659-74d5-9734-15dfefafd3ea@deltatee.com>
 <20190129191120.GE3176@redhat.com>
 <20190129193250.GK10108@mellanox.com>
 <99c228c6-ef96-7594-cb43-78931966c75d@deltatee.com>
 <20190129205827.GM10108@mellanox.com>
 <20190130080208.GC29665@lst.de>
 <4e0637ba-0d7c-66a5-d3de-bc1e7dc7c0ef@amd.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <4e0637ba-0d7c-66a5-d3de-bc1e7dc7c0ef@amd.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.26]); Wed, 30 Jan 2019 15:55:47 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jan 30, 2019 at 10:33:39AM +0000, Koenig, Christian wrote:
> Am 30.01.19 um 09:02 schrieb Christoph Hellwig:
> > On Tue, Jan 29, 2019 at 08:58:35PM +0000, Jason Gunthorpe wrote:
> >> On Tue, Jan 29, 2019 at 01:39:49PM -0700, Logan Gunthorpe wrote:
> >>
> >>> implement the mapping. And I don't think we should have 'special' vma's
> >>> for this (though we may need something to ensure we don't get mapping
> >>> requests mixed with different types of pages...).
> >> I think Jerome explained the point here is to have a 'special vma'
> >> rather than a 'special struct page' as, really, we don't need a
> >> struct page at all to make this work.
> >>
> >> If I recall your earlier attempts at adding struct page for BAR
> >> memory, it ran aground on issues related to O_DIRECT/sgls, etc, etc.
> > Struct page is what makes O_DIRECT work, using sgls or biovecs, etc on
> > it work.  Without struct page none of the above can work at all.  That
> > is why we use struct page for backing BARs in the existing P2P code.
> > Not that I'm a particular fan of creating struct page for this device
> > memory, but without major invasive surgery to large parts of the kernel
> > it is the only way to make it work.
> 
> The problem seems to be that struct page does two things:
> 
> 1. Memory management for system memory.
> 2. The object to work with in the I/O layer.
> 
> This was done because a good part of that stuff overlaps, like reference 
> counting how often a page is used.  The problem now is that this doesn't 
> work very well for device memory in some cases.
> 
> For example on GPUs you usually have a large amount of memory which is 
> not even accessible by the CPU. In other words you can't easily create a 
> struct page for it because you can't reference it with a physical CPU 
> address.
> 
> Maybe struct page should be split up into smaller structures? I mean 
> it's really overloaded with data.

I think the simpler answer is that we do not want to allow GUP or any-
thing similar to pin BAR or device memory. Doing so can only hurt us
long term by fragmenting the GPU memory and forbidding us to move thing
around. For transparent use of device memory within a process this is
definitly forbidden to pin.

I do not see any good reasons we would like to pin device memory for
the existing GPU GEM objects. Userspace always had a very low expectation
on what it can do with mmap of those object and i believe it is better
to keep expectation low here and says nothing will work with those
pointer. I just do not see a valid and compelling use case to change
that :)

Even outside GPU driver, device driver like RDMA just want to share their
doorbell to other device and they do not want to see those doorbell page
use in direct I/O or anything similar AFAICT.

Cheers,
Jérôme

