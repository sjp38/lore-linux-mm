Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 439A7C282D8
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 18:05:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0894A218A4
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 18:05:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0894A218A4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AE04B8E0003; Wed, 30 Jan 2019 13:05:47 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A90EB8E0001; Wed, 30 Jan 2019 13:05:47 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 959438E0003; Wed, 30 Jan 2019 13:05:47 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6778B8E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 13:05:47 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id n50so473745qtb.9
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 10:05:47 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=wLwzo/8FbOdPDHstwg6nsrb1wgpv9Toakbq0vtMxp2U=;
        b=b4l5nTSfMEGrr/xbh5R2bCvmpItOq+H4qxfe6UZw34qNcBLgy7mH6VrX8Xw7hFiz24
         K4YD5yRgjn6YDCtxAqHvoS1Lo2aX2Aa2xwI5LZM4yYnlfIZYQ90/e0C13Z52tzrhUiNx
         XnRpt39UMP8M8HvQwk1I2U30n0j55ZioKZr3Z4A3F5ym27pz2/i7N40A8ymYbGmpK+WB
         3PajXqGGnbECrs7xAxacqdAtJXUX3H4UqIiKXRljyKj4nOLVJPuQ16e0xglQDJtUKFEm
         Ar9qAw8kQtebw8qeaBK+LUHbkMuyAdB8K7vpvPuIW/8teUzCvyymDSXtjZeLSYlyufzo
         lOiQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AJcUukf/elz29DkBBC2SQiWqrTKVdbTuzlOW95KQqPm7iyjgnZQrZJFC
	q/HTWK8tWqSECGYdH6Uz3IGSj2vQk85CrsZAbB2ppB38jRgYDL2xbxxBp4gfXIV7E1XMEcUdF71
	cC7IKSDbg89UGfxsAFDSb0f887u35BveyHtXjLmCY2Mr5PX1qUMC0l0gjYXUO2zriHg==
X-Received: by 2002:ac8:35eb:: with SMTP id l40mr31992396qtb.165.1548871547164;
        Wed, 30 Jan 2019 10:05:47 -0800 (PST)
X-Google-Smtp-Source: ALg8bN7bpB+gjXCa0qM+SMD21H7rrdFd4iuIsK/4BGHIby7ROXemmCZ9b4gS5SjsXhMGzukFKGJO
X-Received: by 2002:ac8:35eb:: with SMTP id l40mr31992358qtb.165.1548871546557;
        Wed, 30 Jan 2019 10:05:46 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548871546; cv=none;
        d=google.com; s=arc-20160816;
        b=ZbYoA5S4S0Wu44LdB8B4J1EU+tbUBShKUGN/yTQch9ev/ivNHH3bCxDOs0xzj4KS0R
         txD5fbuTo+cOMsnhLaV1jnCq+eE5tbnLGiVNEhlL86BX10CYYGibZambufUZ0cwKxxc0
         svg4kCSifesG+s1BqQsC3YWYWdvq/0WIjC3Weuoi9e3TQ6EKgyhscOS3yAoF9KQtunq4
         puFt4nn1/KhSdEjZ2eH+NV2KtCwm9SycnvbwO4B2dk9bMntBzgOeBuEkQHCqoHNJxXYr
         gMRWUdhczmubyYxudOmhmq35sEKgDXxgLAK1t+RmfGEFcytgN3HbPJtUcTqiOBFSYzar
         51GA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=wLwzo/8FbOdPDHstwg6nsrb1wgpv9Toakbq0vtMxp2U=;
        b=DLx/A9bAXp06AAudSlfTFOhO1phyfckIQ8V4TEGkER0PmjBD2etzNtKLg8Piw0pC/K
         /N1xq64onbYak+VgnjpWDPin+dckqFlNXbwp3Haa9ugsVF9QLzWa4rea1a+IOylGgAdC
         Bl1GwwIpyEJzqOjOQcAufJHLECaywfSzaTZ+IhoLPOKpIFDdHj1C3+x/tnW4/XxzeqUO
         18qawst2oaQ8XUTqUEj10V2piSZhE4sHC2t9kyYKtqH9aRllnw/RpRhOyuyC9nz9Dgk3
         Vj1/04oVAPQxI1tSZlGBYTWG5HhqpHhiRPMS/+uDR7tydmX4+eto7TkWDWs38S6xrYHX
         ZgYw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u56si1494385qvc.4.2019.01.30.10.05.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Jan 2019 10:05:46 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 3F72D89ACD;
	Wed, 30 Jan 2019 18:05:45 +0000 (UTC)
Received: from redhat.com (ovpn-126-0.rdu2.redhat.com [10.10.126.0])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 33CD55C21A;
	Wed, 30 Jan 2019 18:05:43 +0000 (UTC)
Date: Wed, 30 Jan 2019 13:05:41 -0500
From: Jerome Glisse <jglisse@redhat.com>
To: Christoph Hellwig <hch@lst.de>
Cc: "Koenig, Christian" <Christian.Koenig@amd.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
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
Message-ID: <20190130180541.GA5061@redhat.com>
References: <20190129174728.6430-4-jglisse@redhat.com>
 <ae928aa5-a659-74d5-9734-15dfefafd3ea@deltatee.com>
 <20190129191120.GE3176@redhat.com>
 <20190129193250.GK10108@mellanox.com>
 <99c228c6-ef96-7594-cb43-78931966c75d@deltatee.com>
 <20190129205827.GM10108@mellanox.com>
 <20190130080208.GC29665@lst.de>
 <4e0637ba-0d7c-66a5-d3de-bc1e7dc7c0ef@amd.com>
 <20190130155543.GC3177@redhat.com>
 <20190130172653.GA6707@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190130172653.GA6707@lst.de>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.26]); Wed, 30 Jan 2019 18:05:45 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jan 30, 2019 at 06:26:53PM +0100, Christoph Hellwig wrote:
> On Wed, Jan 30, 2019 at 10:55:43AM -0500, Jerome Glisse wrote:
> > Even outside GPU driver, device driver like RDMA just want to share their
> > doorbell to other device and they do not want to see those doorbell page
> > use in direct I/O or anything similar AFAICT.
> 
> At least Mellanox HCA support and inline data feature where you
> can copy data directly into the BAR.  For something like a usrspace
> NVMe target it might be very useful to do direct I/O straight into
> the BAR for that.

And what i am proposing is not exclusive of that. If exporting device
wants to have struct page for its BAR than it can do so. What i do not
want is imposing that burden on everyone as many devices do not want
or do not care for that. Moreover having struct page and allowing that
struct page to trickle know in obscure corner of the kernel means that
exporter that want that will also have the burden to check that what
they are doing does not end up in something terribly bad.

While i would like a one API fits all i do not think that we can sanely
do that for P2P. They are too much differences between how different
devices expose and manage their BAR to make any such attempt reasonably
sane.

Maybe thing will evolve oragnicaly, but for now i do not see a way out
side the API i am proposing (again this is not exclusive of the struct
page API that is upstream both can co-exist and a device can use both
or just one).

Cheers,
Jérôme

