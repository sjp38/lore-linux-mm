Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C0197C282D9
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 15:49:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 883FE21473
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 15:49:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 883FE21473
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1A8018E0006; Wed, 30 Jan 2019 10:49:22 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 156E78E0001; Wed, 30 Jan 2019 10:49:22 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 049398E0006; Wed, 30 Jan 2019 10:49:22 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id CF6D28E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 10:49:21 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id k66so19221qkf.1
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 07:49:21 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=kY7jAJk7Jdb0JLqR74DNGNRbyltdoLCYY2bKrEmARrs=;
        b=bmo2c5QHKANo+6ILTmNndWi47dmwdoqpb0mssgVep9s836CLRV6GFt9KOaMeDja9vp
         6ky/kfXyvJpUeOYv1maEvY/h1MPetW+XZBgXX3m3S+qvV2PRBuLhGxJlP4iwKSHaJeeK
         ct6l/6LBxQwWtbh3Gdj/fhLfVx/o7fHoDCTg9RR8+l0n1S6RIqbTUQPLiOXzXXFz6Tzr
         gT/4iaB6fakrZ/bfa7NfkNAuc27JGiczycpWSoL2wQpE4fdep0Di7T/g5cpVlol5nXWx
         bY+rWfnIdZRjs415COXdqZv2ujCzcFGVnupAiadVhIc0kbB/3BXNryUfRdA6wkpe8Gdb
         pjgA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AJcUukeLW8kpoDPzme6SCdPF7+wf7c+9DGSJNNx/coUmlZORocSN2KNo
	UchOZSOvNR+BOemxOe+BZeuWL7i3UIevaTR+5Q1B5RR1oBOTVv7Ccvw+2K/j7QvBHQECk/JPrWL
	m8ek9rBymG2Y10/AbINKqcUOXuiI17JCQCkbzYt1ShXGmRqBBUpzj1CmshFbBua/fJA==
X-Received: by 2002:a37:9cce:: with SMTP id f197mr28237120qke.98.1548863361632;
        Wed, 30 Jan 2019 07:49:21 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4tBzgkrA8FiBLl5fekzqFUilQjRUR58KnXr//ovixW9CGtc6wXAzC3+Wpc+3BLnuFuctsu
X-Received: by 2002:a37:9cce:: with SMTP id f197mr28237085qke.98.1548863360889;
        Wed, 30 Jan 2019 07:49:20 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548863360; cv=none;
        d=google.com; s=arc-20160816;
        b=lfUgy+AcXQDHXRdv0x2dkZXssjGSAVt4U0+ptLjnlCjz364QPaazR8nLkWxWYRar9b
         dJzva8g9e7dg0uzf9R3NQ9F0nMxLbkKYDKHMYzFWyY/KvkVCX/SwcCTS0ZbndS4hG2z4
         7SfVZ0bn4xH1HvGALFbaV7+fIcFf84Hm6Plro0BcRokAVyzQTFqIPL6Bl5iysE2In5Cx
         Eh/WVSkCMp2qyeMkEDGNaYrHtaDCjJIxOP0oE+eSBgk6M+dipD2cKPG5bnA37bKmvUnJ
         FA8PwCPjt19G2QkcMf+GWsbBg06WNl7SL1CaRYVMt160wdrVC7yhybu35SgG8UP8OF4N
         DHqg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=kY7jAJk7Jdb0JLqR74DNGNRbyltdoLCYY2bKrEmARrs=;
        b=gUzNmj4PU4QS2Z6Gc/2hBzjBOp9f6P9S7/7AyyLo0QU+Mbk8S8cadTArCJXvshcl6X
         ZwHAZqfp4IGK6C215aT8TvfT7OpRtZJbqwULPndcYookTmWkQ+GQIeFbBUvJYh5qN6te
         X9TV5RqeiukVQboVaUaG3ZGJJZm0wvPwzoVV2uQhEU1CpfAAaBMgbaCU4FvHZAXV1F7N
         ZJQRKiQdbw+Sar/VEGW+o7g1fDwRJ1TnyrZFflX1Y+wK+pj2IBmO1Jq402QXpGKb9wIV
         u3ce3lk16v94hZxobLuYiz5/8PbL23TnLLRrTDgzX7ms6u2hjuc0qyGziBl0GhlQwydf
         tCNQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h1si996286qtj.131.2019.01.30.07.49.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Jan 2019 07:49:20 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 9F4787AEA1;
	Wed, 30 Jan 2019 15:49:19 +0000 (UTC)
Received: from redhat.com (ovpn-126-0.rdu2.redhat.com [10.10.126.0])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id C7FEC5D6A6;
	Wed, 30 Jan 2019 15:49:17 +0000 (UTC)
Date: Wed, 30 Jan 2019 10:49:16 -0500
From: Jerome Glisse <jglisse@redhat.com>
To: Christoph Hellwig <hch@lst.de>
Cc: Jason Gunthorpe <jgg@mellanox.com>,
	Logan Gunthorpe <logang@deltatee.com>,
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
Message-ID: <20190130154915.GB3177@redhat.com>
References: <20190129193250.GK10108@mellanox.com>
 <99c228c6-ef96-7594-cb43-78931966c75d@deltatee.com>
 <20190129205749.GN3176@redhat.com>
 <2b704e96-9c7c-3024-b87f-364b9ba22208@deltatee.com>
 <20190129215028.GQ3176@redhat.com>
 <deb7ba21-77f8-0513-2524-ee40a8ee35d5@deltatee.com>
 <20190129234752.GR3176@redhat.com>
 <655a335c-ab91-d1fc-1ed3-b5f0d37c6226@deltatee.com>
 <20190130041841.GB30598@mellanox.com>
 <20190130080006.GB29665@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190130080006.GB29665@lst.de>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Wed, 30 Jan 2019 15:49:20 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jan 30, 2019 at 09:00:06AM +0100, Christoph Hellwig wrote:
> On Wed, Jan 30, 2019 at 04:18:48AM +0000, Jason Gunthorpe wrote:
> > Every attempt to give BAR memory to struct page has run into major
> > trouble, IMHO, so I like that this approach avoids that.
> 
> Way less problems than not having struct page for doing anything
> non-trivial.  If you map the BAR to userspace with remap_pfn_range
> and friends the mapping is indeed very simple.  But any operation
> that expects a page structure, which is at least everything using
> get_user_pages won't work.
> 
> So you can't do direct I/O to your remapped BAR, you can't create MRs
> on it, etc, etc.

We do not want direct I/O, in fact at least for GPU we want to seldomly
allow access to object vma, so the less thing can access it the happier
we are :) All the GPU userspace driver API (OpenGL, OpenCL, Vulkan, ...)
that expose any such mapping with the application are very clear on the
limitation which is often worded: the only valid thing is direct CPU
access (no syscall can be use with those pointers).

So application developer already have low expectation on what is valid
and allowed to do.

Cheers,
Jérôme

