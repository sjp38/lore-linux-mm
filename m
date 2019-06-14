Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 522DEC31E4C
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 15:05:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1A2B620866
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 15:05:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1A2B620866
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BC3256B0007; Fri, 14 Jun 2019 11:05:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B99E66B0008; Fri, 14 Jun 2019 11:05:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AAFD16B000A; Fri, 14 Jun 2019 11:05:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6014E6B0007
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 11:05:39 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id c1so4015953edi.20
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 08:05:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=DjkZXDL3Gvxsu6J18pQR94tIMtNL2DLRVD1lz6EUugY=;
        b=HSy9LUePvPjcn5X0qe5HQgGl6wYJ6s8cJ+BXD3875DClJomPFHeSpqWEvJ1PBhEeMK
         RSXfFPeVcka48oy9pNiQV78nltbbiO+Nc3bzb9YHDFZME2yC5qnM/HPkpYBjNmGQVMPe
         1slGuWHTqmpWpSWxoFBTP2vdgmz5Swf8lstnoT+m4bVMknbwB1IAgzF/wx67Js0U5GIw
         MAUIL3SopjG8IuXMMkk874d/A5lUdVWjhwl+WRX+qoVL6yqNMI+xqbsrZBWJQEMFsxie
         RJjLA2vvikXeFcTp91COdC77TMdNp3o5OybSkzp7MXoBrxCv6ccKF2uzk0dCrPGtGG1i
         0VsA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of robin.murphy@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
X-Gm-Message-State: APjAAAVtLKDD6r6fmcHulwFDuvTTX5Oe3830mHaC84ui9w0dIjF+Pm22
	mDHSTQdrtYBMrRAbwNMEbxSB+5cI5NFHIRdVMBO94fMkY6OV6mZbUjhbRBWSnvW/BtJ6E1YR3V/
	waCjNLqDmzktaL+AdBaUapnfVzyOUvt5wrTrbbr7J7LSPoUzE38+Kc+U7dZUX6gIEHw==
X-Received: by 2002:a17:906:3098:: with SMTP id 24mr58302222ejv.106.1560524738943;
        Fri, 14 Jun 2019 08:05:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyh7TU1kj5hE6IJRkBUG65Ww6qlAhPE1cz/n+I9t9vbCevCRei4HW4y7R0b7ZulLr7uLMsW
X-Received: by 2002:a17:906:3098:: with SMTP id 24mr58302140ejv.106.1560524738177;
        Fri, 14 Jun 2019 08:05:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560524738; cv=none;
        d=google.com; s=arc-20160816;
        b=t1g0Ojw1/+S/oS6YQAKBTDnvrt4gMaB0/O7EhIbJyu2XVTz+PnUdsx7M4aCzp7wjhX
         ibOxOVOE28FcNwQp8mRGesxwUO0IlHUDoF2qn0qpqEIaoE2FWL7Goi9hH2dFL368Htvf
         5oo+sjE0bn2c3Te+ij/kHosNSldBLJAKCkSzO/5MVnlNrdWTmekb1xXs9nI7KEQI4K6+
         DOiPHgTyUm/kPYpYyBTpr8y25mgXjALmB+HAxvoGpXX84hcCyi/RMRdgYryF5rv700yk
         iWvumoiqdphtlL33bvTCh/SEiB4jcUQgi1REWjbp9nRPtNbqTeiCZcLG8PcekBtZfwFT
         VSZA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=DjkZXDL3Gvxsu6J18pQR94tIMtNL2DLRVD1lz6EUugY=;
        b=cqAW7c7Oyws9Ad6CZsDKiT0VNjB7HKbmXUTAWx9ao6IJDAKx+rR7LbCZBpYJi5W+fU
         tWTpPDCgXe2cMnfDhiOVQtaN4UQyuxfN/4Nn8+U4m7g57V5vKVl7sPixqfQB6BzC/cYw
         suBk5ljJ4iPZ1bzn5OtbuoStPCvzM67eUy7tCb3zY+r9JcdGPhvUe99Q7zmyIJPhdKqP
         L60ZPoOejt4FL8tXVvjyc4XEUTQ36ZT5crr+B3KGATqPrGdjuhlZ62hI7sJ6U9GStKw/
         TECEnbMrwDAXQP9mqdiEc6skWNmuzutvK/sgTm56GBNCTtNQgW5dvzdyd9hg/4FFYHu4
         pRMw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of robin.murphy@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id v26si2167110edy.37.2019.06.14.08.05.37
        for <linux-mm@kvack.org>;
        Fri, 14 Jun 2019 08:05:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of robin.murphy@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of robin.murphy@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 4E8F2344;
	Fri, 14 Jun 2019 08:05:37 -0700 (PDT)
Received: from [10.1.197.57] (e110467-lin.cambridge.arm.com [10.1.197.57])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 5B1F93F246;
	Fri, 14 Jun 2019 08:05:34 -0700 (PDT)
Subject: Re: [PATCH 16/16] dma-mapping: use exact allocation in
 dma_alloc_contiguous
To: 'Christoph Hellwig' <hch@lst.de>, David Laight <David.Laight@ACULAB.COM>
Cc: Maxime Ripard <maxime.ripard@bootlin.com>,
 Joonas Lahtinen <joonas.lahtinen@linux.intel.com>,
 "dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
 "linux-mm@kvack.org" <linux-mm@kvack.org>,
 "devel@driverdev.osuosl.org" <devel@driverdev.osuosl.org>,
 "linux-s390@vger.kernel.org" <linux-s390@vger.kernel.org>,
 "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
 David Airlie <airlied@linux.ie>,
 "linux-media@vger.kernel.org" <linux-media@vger.kernel.org>,
 Intel Linux Wireless <linuxwifi@intel.com>,
 "intel-gfx@lists.freedesktop.org" <intel-gfx@lists.freedesktop.org>,
 Maarten Lankhorst <maarten.lankhorst@linux.intel.com>,
 Jani Nikula <jani.nikula@linux.intel.com>, Ian Abbott <abbotti@mev.co.uk>,
 Rodrigo Vivi <rodrigo.vivi@intel.com>, Sean Paul <sean@poorly.run>,
 "moderated list:ARM PORT" <linux-arm-kernel@lists.infradead.org>,
 "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 H Hartley Sweeten <hsweeten@visionengravers.com>,
 "iommu@lists.linux-foundation.org" <iommu@lists.linux-foundation.org>,
 Daniel Vetter <daniel@ffwll.ch>
References: <20190614134726.3827-1-hch@lst.de>
 <20190614134726.3827-17-hch@lst.de>
 <a90cf7ec5f1c4166b53c40e06d4d832a@AcuMS.aculab.com>
 <20190614145001.GB9088@lst.de>
From: Robin Murphy <robin.murphy@arm.com>
Message-ID: <4113cd5f-5c13-e9c7-bc5e-dcf0b60e7054@arm.com>
Date: Fri, 14 Jun 2019 16:05:33 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190614145001.GB9088@lst.de>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 14/06/2019 15:50, 'Christoph Hellwig' wrote:
> On Fri, Jun 14, 2019 at 02:15:44PM +0000, David Laight wrote:
>> Does this still guarantee that requests for 16k will not cross a 16k boundary?
>> It looks like you are losing the alignment parameter.
> 
> The DMA API never gave you alignment guarantees to start with,
> and you can get not naturally aligned memory from many of our
> current implementations.

Well, apart from the bit in DMA-API-HOWTO which has said this since 
forever (well, before Git history, at least):

"The CPU virtual address and the DMA address are both
guaranteed to be aligned to the smallest PAGE_SIZE order which
is greater than or equal to the requested size.  This invariant
exists (for example) to guarantee that if you allocate a chunk
which is smaller than or equal to 64 kilobytes, the extent of the
buffer you receive will not cross a 64K boundary."

That said, I don't believe this particular patch should make any 
appreciable difference - alloc_pages_exact() is still going to give back 
the same base address as the rounded up over-allocation would, and 
PAGE_ALIGN()ing the size passed to get_order() already seemed to be 
pointless.

Robin.

