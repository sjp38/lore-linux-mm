Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 53CFDC282D7
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 22:30:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D273D2086C
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 22:30:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D273D2086C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 904668E0002; Wed, 30 Jan 2019 17:30:34 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8B1958E0001; Wed, 30 Jan 2019 17:30:34 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7A1708E0002; Wed, 30 Jan 2019 17:30:34 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 524AF8E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 17:30:34 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id f2so1353336qtg.14
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 14:30:34 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=zl5tEBSn7M659gOtGw/mDuQW6d7a3B3kGp0yEdxEcUs=;
        b=SRkh5YFH88UHin0ibIg9Sht0bBxpA+Qezmn1DxiOM1iYfKAi+hDIWmQ3vdtH8+mT44
         QP+1VpcACt8I0FSlqHlZaDLF9L4Qn/IPkpe9BBkeNEHYXbIlAmg4WBXgGxXLvp6kCvVI
         97ogQlsqey513UWXU6P4KAn75L8n51V2DJTrYpr/NXO+SOb2ssusflBiLA+fh4EUTtPQ
         KvY8SEO6awRjciaZQZLJk935cpmagni1xKrI93BL/KFsU5zcRMe73nYiMbDCZV+rJ4/y
         6GkLIvhCZCUOavp3Adzxh2cCBhe8iBv3I2jdKE9sus++uFjYzgCyEXfvoLEfu4vFUBV5
         x7iw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AJcUuke2dfLHFTfWqWUXcpwM8Pq0zazikZJdAwvL0PVQGAMDNX3P+G8u
	exgu92bohr7jEJl89kQN8vw9+xE/C9DCenJgiWe5gs7IiwIbCSBzYYx7ml+txMlT+pteSc1H/WN
	PjWOLYX++G8x/MVrFbaa8o/pddJRbcXbebelKGwaxsFb1Q34UshzAPYPdyLsJBu4mYw==
X-Received: by 2002:a0c:bd15:: with SMTP id m21mr30294062qvg.57.1548887434083;
        Wed, 30 Jan 2019 14:30:34 -0800 (PST)
X-Google-Smtp-Source: ALg8bN5bwkNlRfqr8rpIzAYqx3SDNpS74HNQoYUi5MKG7n6XQkddtYHTXn3EkUtdYMGs+LnVg6gI
X-Received: by 2002:a0c:bd15:: with SMTP id m21mr30294021qvg.57.1548887433222;
        Wed, 30 Jan 2019 14:30:33 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548887433; cv=none;
        d=google.com; s=arc-20160816;
        b=sv8S2zuzCqiNZG1RlJ9LQz4x9UuQnABEW0xWNhblVHZMBVn43lIrl0HBK3YqP4C1jS
         U492X1UCpYr6JFoIwz/olV1DOXPXo8Vyemu91oLLi/QwUBZ1Dn919z43bCmfJpiSBIni
         1S/+7xlmC2J4vGSde4ydUU7kSiIvw0bYw9nzcnFqlgsvikhYEZm51XafGuhrywjvXaWI
         wOqlrtVuJ7na7fT6jhr9O+Gc+esKfmyXhS4sHOgCDIMNjWr49bdc33AlsJU12WoV5m20
         HedP2am/Ahazvw6cJmikYWH/DhQw+RtdPFHtPi+dPWtvZpHdOOGtsnPk7VBvzHdGYitV
         KYKA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=zl5tEBSn7M659gOtGw/mDuQW6d7a3B3kGp0yEdxEcUs=;
        b=eQOqpA2+7kV28b21ksSEUcQ6pRrORX2JWdkddbr4C1usAnAcA9f4PGJTfn/gukrE9+
         zTB23UctGNBAaqRXqTNP0G0g+f/8hABnrBRw3pXQY+pnb2AjIAmI/tBZK4yPOObVTLLa
         lzdxmUumFU5TmJZJXv9wcr73Q1ZmonCap4oZuifMuHzFuyHXf3zrMLwPike50MSWrQZ+
         7DrCXA0yitY+3GK1tS74QmQdPQIpWR9zZ2WOVSD+EcZqyf53vKmCf/AXaRzoSgFRxyDD
         6DsiTOCDnVMxshplpgQlSptFyhjloBf+Jma8UfbDAlTbeM5p8MYPnVlr7BAwCjUIKVJY
         miRA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w5si1252061qvi.223.2019.01.30.14.30.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Jan 2019 14:30:33 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id BACE8C0C6C2B;
	Wed, 30 Jan 2019 22:30:31 +0000 (UTC)
Received: from redhat.com (ovpn-126-0.rdu2.redhat.com [10.10.126.0])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 98B08608C6;
	Wed, 30 Jan 2019 22:30:29 +0000 (UTC)
Date: Wed, 30 Jan 2019 17:30:27 -0500
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
Message-ID: <20190130223027.GH5061@redhat.com>
References: <bdf03cd5-f5b1-4b78-a40e-b24024ca8c9f@deltatee.com>
 <20190130185652.GB17080@mellanox.com>
 <20190130192234.GD5061@redhat.com>
 <20190130193759.GE17080@mellanox.com>
 <db873687-ff80-4758-0b9f-973f27db5335@deltatee.com>
 <20190130201114.GB17915@mellanox.com>
 <20190130204332.GF5061@redhat.com>
 <20190130204954.GI17080@mellanox.com>
 <20190130214525.GG5061@redhat.com>
 <20190130215600.GM17080@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190130215600.GM17080@mellanox.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.32]); Wed, 30 Jan 2019 22:30:32 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jan 30, 2019 at 09:56:07PM +0000, Jason Gunthorpe wrote:
> On Wed, Jan 30, 2019 at 04:45:25PM -0500, Jerome Glisse wrote:
> > On Wed, Jan 30, 2019 at 08:50:00PM +0000, Jason Gunthorpe wrote:
> > > On Wed, Jan 30, 2019 at 03:43:32PM -0500, Jerome Glisse wrote:
> > > > On Wed, Jan 30, 2019 at 08:11:19PM +0000, Jason Gunthorpe wrote:
> > > > > On Wed, Jan 30, 2019 at 01:00:02PM -0700, Logan Gunthorpe wrote:
> > > > > 
> > > > > > We never changed SGLs. We still use them to pass p2pdma pages, only we
> > > > > > need to be a bit careful where we send the entire SGL. I see no reason
> > > > > > why we can't continue to be careful once their in userspace if there's
> > > > > > something in GUP to deny them.
> > > > > > 
> > > > > > It would be nice to have heterogeneous SGLs and it is something we
> > > > > > should work toward but in practice they aren't really necessary at the
> > > > > > moment.
> > > > > 
> > > > > RDMA generally cannot cope well with an API that requires homogeneous
> > > > > SGLs.. User space can construct complex MRs (particularly with the
> > > > > proposed SGL MR flow) and we must marshal that into a single SGL or
> > > > > the drivers fall apart.
> > > > > 
> > > > > Jerome explained that GPU is worse, a single VMA may have a random mix
> > > > > of CPU or device pages..
> > > > > 
> > > > > This is a pretty big blocker that would have to somehow be fixed.
> > > > 
> > > > Note that HMM takes care of that RDMA ODP with my ODP to HMM patch,
> > > > so what you get for an ODP umem is just a list of dma address you
> > > > can program your device to. The aim is to avoid the driver to care
> > > > about that. The access policy when the UMEM object is created by
> > > > userspace through verbs API should however ascertain that for mmap
> > > > of device file it is only creating a UMEM that is fully covered by
> > > > one and only one vma. GPU device driver will have one vma per logical
> > > > GPU object. I expect other kind of device do that same so that they
> > > > can match a vma to a unique object in their driver.
> > > 
> > > A one VMA rule is not really workable.
> > > 
> > > With ODP VMA boundaries can move around across the lifetime of the MR
> > > and we have no obvious way to fail anything if userpace puts a VMA
> > > boundary in the middle of an existing ODP MR address range.
> > 
> > This is true only for vma that are not mmap of a device file. This is
> > what i was trying to get accross. An mmap of a file is never merge
> > so it can only get split/butcher by munmap/mremap but when that happen
> > you also need to reflect the virtual address space change to the
> > device ie any access to a now invalid range must trigger error.
> 
> Why is it invalid? The address range still has valid process memory?

If you do munmap(A, size) then all address in the range [A, A+size]
are invalid. This is what i am refering too here. Same for mremap.

> 
> What is the problem in the HMM mirror that it needs this restriction?

No restriction at all here. I think i just wasn't understood.

> There is also the situation where we create an ODP MR that spans 0 ->
> U64_MAX in the process address space. In this case there are lots of
> different VMAs it covers and we expect it to fully track all changes
> to all VMAs.

Yes and that works however any memory access above TASK_SIZE will
return -EFAULT as this is kernel address space so you can only access
anything that is a valid process virtual address.

> 
> So we have to spin up dedicated umem_odps that carefully span single
> VMAs, and somehow track changes to VMA ?

No you do not.

> 
> mlx5 odp does some of this already.. But yikes, this needs some pretty
> careful testing in all these situations.

Sorry if i confused you even more than the first time. Everything works
you have nothing to worry about :)

> 
> > > I think the HMM mirror API really needs to deal with this for the
> > > driver somehow.
> > 
> > Yes the HMM does deal with this for you, you do not have to worry about
> > it. Sorry if that was not clear. I just wanted to stress that vma that
> > are mmap of a file do not behave like other vma hence when you create
> > the UMEM you can check for those if you feel the need.
> 
> What properties do we get from HMM mirror? Will it tell us when to
> create more umems to cover VMA seams or will it just cause undesired
> no-mapped failures in some cases?

You do not get anything from HMM mirror, i might add a flag so that
HMM can report this special condition if driver wants to know. If
you want to know you have to look at the vma by yourself. GPU driver
will definitly want to know whem importing so i might add a flag so
that they do not have to lookup the vma themself to know.

Again if you do not care then just ignore everything here, it is
handled by HMM and you do not have to worry one bit. If it worked
with GUP it will work with HMM and with those p2p patches if it
will even works against vma that are mmap of a file and that set
the p2p_map function.

Cheers,
Jérôme

