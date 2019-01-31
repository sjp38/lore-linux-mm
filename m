Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BBD83C282D9
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 08:13:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 941A620863
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 08:13:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 941A620863
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1F7448E0003; Thu, 31 Jan 2019 03:13:58 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1A7398E0001; Thu, 31 Jan 2019 03:13:58 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 095AB8E0003; Thu, 31 Jan 2019 03:13:58 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f72.google.com (mail-wr1-f72.google.com [209.85.221.72])
	by kanga.kvack.org (Postfix) with ESMTP id A95188E0001
	for <linux-mm@kvack.org>; Thu, 31 Jan 2019 03:13:57 -0500 (EST)
Received: by mail-wr1-f72.google.com with SMTP id h11so779003wrs.2
        for <linux-mm@kvack.org>; Thu, 31 Jan 2019 00:13:57 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Acblo/+uJNdHMW4pb8e5e4aiH0t/0RVfvjUck2tlkTY=;
        b=ZpUw4jjDGxo6p3JyWWICY6MGANw4Z19Rx7XSPOGcT/TXMUEIhB+XvvYqV9dntjDq5z
         dzHy77hQU+BZCAiFQnktq1nqJ4tkUSv6zmeYrV6rGqad+u2vDg15P4X5wj1A1QZf1jLm
         xaVFSMfYTyN6Nm1uGJYUThwj3zMtkMDFmfC3s6cINMIxnCuik/DWaWTm4DGpQkC6xNe2
         wYBU/b9t0aYTw6Q2LKcvQqGCKHaDs5+CG3GD9r/AWsvL1EgGwR5bjqBWEFD6lxYZEKbS
         Jl9xxb/g/I3pvsFwW32zFS12u45F9uacA8m8warMocW5i5xZRNHKCOqghZFCJdo5zXlQ
         15QA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: AJcUukdCvSm7uLTK19ZXW7p5+ZIgapuTEVny4vXZq03t0vIL4KyCJvjM
	Xz75fz+tf7YfI3K7Df/+RfdfO6ITDYGZsB93I3mUkn2Uqzqxcizl2VcS6mIqXWsXkyttIEGAvn1
	42/YMFUy3JV6aoHzfvOzL24mn7fk9YAZBVmk6uEq2AWwE2GvOq5eOHEbBbqD0ikKQlw==
X-Received: by 2002:a1c:7719:: with SMTP id t25mr30344768wmi.7.1548922437097;
        Thu, 31 Jan 2019 00:13:57 -0800 (PST)
X-Google-Smtp-Source: ALg8bN60xB206mCL4VMGgLA56W6Ihm8J1/pDK05JHi96wITduQc3J7G7Wvb+zeM2oZ8a+4ZT3Sao
X-Received: by 2002:a1c:7719:: with SMTP id t25mr30344735wmi.7.1548922436318;
        Thu, 31 Jan 2019 00:13:56 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548922436; cv=none;
        d=google.com; s=arc-20160816;
        b=BLqpTla4zqtbpyi9vlao+PxteRK1P2HUxfCui3UBZwzxhKUB5zRypzWOQ2BoMRJFoA
         x4P+dqP2ZTGYYapuG4LopooLq6RFcNpA9HGS6/rXk2Zrx7tO9DkA2D2SOqLnbgL7IrSN
         WoycqnsT3RSGMvtbkn6wDPT/buUYNXpMhLAZdkMPPnuU7bUvW00LQ51IYH1RmwCGtBXJ
         337I+5aCrOo0xazobZgf6T5ioBnbHgHBDCuWyxbRXkataps3H3Ryok7dWynKKp5nsU7w
         Kq6VH4nUWJuC7LmXAN2VVSB0wbqFCjiOIAIH7C3ROr46dOHT2xnZpBKjpiQbeE7AAaUd
         hezg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Acblo/+uJNdHMW4pb8e5e4aiH0t/0RVfvjUck2tlkTY=;
        b=brJi/kfsvDBROrw7cbcChloh2KjXzRPiF7VTLMVGZo8TN3sgwtwuCd7tiJxhS0C9Wa
         f3YH5affAdB2OLvbCVWvgd2jg3codGUECAtmY2Xdnp49eXlj+eMLzmsq72/RNAZv05Ud
         HXjsZu1ysyZLz1of0Xk34TR+B4f3N2j6EYbNUYG65j85R5J6lrKx4s8cY3yLL8w1TJv8
         6UjP+qyUS8G/Qal8laJCVplIcJLDArwRaIFjHZrxm8uRUTg72X1OV41E0hYEXJG0gvap
         w9wEMx4hoJdkd8mz5oIzu/X5yga84V3R1+rNiwojWGNi/KYWegujdembV1fMvhUIc63+
         KXfg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id t205si3102278wmg.165.2019.01.31.00.13.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Jan 2019 00:13:56 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id 9A19368CEB; Thu, 31 Jan 2019 09:13:55 +0100 (CET)
Date: Thu, 31 Jan 2019 09:13:55 +0100
From: Christoph Hellwig <hch@lst.de>
To: Logan Gunthorpe <logang@deltatee.com>
Cc: Jason Gunthorpe <jgg@mellanox.com>, Christoph Hellwig <hch@lst.de>,
	Jerome Glisse <jglisse@redhat.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"Rafael J . Wysocki" <rafael@kernel.org>,
	Bjorn Helgaas <bhelgaas@google.com>,
	Christian Koenig <christian.koenig@amd.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	Marek Szyprowski <m.szyprowski@samsung.com>,
	Robin Murphy <robin.murphy@arm.com>, Joerg Roedel <jroedel@suse.de>,
	"iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>
Subject: Re: [RFC PATCH 3/5] mm/vma: add support for peer to peer to device
 vma
Message-ID: <20190131081355.GC26495@lst.de>
References: <20190129234752.GR3176@redhat.com> <655a335c-ab91-d1fc-1ed3-b5f0d37c6226@deltatee.com> <20190130041841.GB30598@mellanox.com> <20190130080006.GB29665@lst.de> <20190130190651.GC17080@mellanox.com> <840256f8-0714-5d7d-e5f5-c96aec5c2c05@deltatee.com> <20190130195900.GG17080@mellanox.com> <35bad6d5-c06b-f2a3-08e6-2ed0197c8691@deltatee.com> <20190130215019.GL17080@mellanox.com> <07baf401-4d63-b830-57e1-5836a5149a0c@deltatee.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <07baf401-4d63-b830-57e1-5836a5149a0c@deltatee.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jan 30, 2019 at 03:52:13PM -0700, Logan Gunthorpe wrote:
> > *shrug* so what if the special GUP called a VMA op instead of
> > traversing the VMA PTEs today? Why does it really matter? It could
> > easily change to a struct page flow tomorrow..
> 
> Well it's so that it's composable. We want the SGL->DMA side to work for
> APIs from kernel space and not have to run a completely different flow
> for kernel drivers than from userspace memory.

Yes, I think that is the important point.

All the other struct page discussion is not about anyone of us wanting
struct page - heck it is a pain to deal with, but then again it is
there for a reason.

In the typical GUP flows we have three uses of a struct page:

 (1) to carry a physical address.  This is mostly through
     struct scatterlist and struct bio_vec.  We could just store
     a magic PFN-like value that encodes the physical address
     and allow looking up a page if it exists, and we had at least
     two attempts at it.  In some way I think that would actually
     make the interfaces cleaner, but Linus has NACKed it in the
     past, so we'll have to convince him first that this is the
     way forward
 (2) to keep a reference to the memory so that it doesn't go away
     under us due to swapping, process exit, unmapping, etc.
     No idea how we want to solve this, but I guess you have
     some smart ideas?
 (3) to make the PTEs dirty after writing to them.  Again no sure
     what our preferred interface here would be

If we solve all of the above problems I'd be more than happy to
go with a non-struct page based interface for BAR P2P.  But we'll
have to solve these issues in a generic way first.

