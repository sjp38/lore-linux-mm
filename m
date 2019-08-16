Return-Path: <SRS0=YXmN=WM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.7 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DF8AEC3A59C
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 17:21:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 91C312064A
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 17:21:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="QCN9eZvx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 91C312064A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 40F586B0006; Fri, 16 Aug 2019 13:21:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3BF2C6B0007; Fri, 16 Aug 2019 13:21:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2D5986B000A; Fri, 16 Aug 2019 13:21:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0046.hostedemail.com [216.40.44.46])
	by kanga.kvack.org (Postfix) with ESMTP id 0F7AD6B0006
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 13:21:55 -0400 (EDT)
Received: from smtpin06.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 9F38E180AD7C1
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 17:21:54 +0000 (UTC)
X-FDA: 75828958548.06.list69_1097fb5bbbb55
X-HE-Tag: list69_1097fb5bbbb55
X-Filterd-Recvd-Size: 4732
Received: from mail-ot1-f67.google.com (mail-ot1-f67.google.com [209.85.210.67])
	by imf32.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 17:21:53 +0000 (UTC)
Received: by mail-ot1-f67.google.com with SMTP id e12so10204112otp.10
        for <linux-mm@kvack.org>; Fri, 16 Aug 2019 10:21:53 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=zMvxega2p/6F2S/eoDzz+sN4i7bM8B+uz60Grtez1JE=;
        b=QCN9eZvxzAPGmUPLnJH/woDtKhvSbyWNPI2WVuuw78XLs8YTeApowbbTpG4QmVhRT8
         KiEz3hmHc4YlVhpGKa4TQ2iVsusMkMmynlM+BCY4q+fdKS3rJPykSdyfO9A3QGOq+bCv
         Ep1qhKfWcW3SsmTBurcp0FktyN0IH0JZXWMk3EtkNfv4UCl45hWL/qKUAJyVWq8HCPc+
         04MySaN5P2L8D4z2nil2AJHtxzcCAXe9+Ae3Qzl3Th1EMpkCiYr6W6vATmErlpeFN+X6
         UckZrP9+cKrZkBK1Mne3Ywq2nD/UZNxrcPAq4iFlzuaxVK76A2sJ0kE48E61MlCk6O69
         /0RQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=zMvxega2p/6F2S/eoDzz+sN4i7bM8B+uz60Grtez1JE=;
        b=c5sAM8yq6i9L9qibAVArPiMcLLbtJCr3h37LcsUCVNHvSQnwix7lV2iwTCQ5OZQZE8
         PXhym40zwuKijVaZJIjkrPuhSdzUGjVQBcR9iaPeVNtZ/ib7bUOUxkK5KnrcuJPEhR3U
         nF9mp4HAaaOIbDg6NSuTRVi3Cb5XqLX8kz6mUrEdM5RSkWXldJxJJs9NVqQAqpxmaOqF
         XPUuw5wRSUP1HTMFYfp8bJX/M7KLdbOB0k9sTMiAme/2DS8vIgiNZZNj0gst6BJcxmsY
         p3s7Rcq4eDSHXWM0v0bvf7tffS1IVOuOnZ1E7u/Xsnt4X+wMGOZFyhYM/Inqf/u09Xl2
         RmwQ==
X-Gm-Message-State: APjAAAXWT9MK3BE1Keb/cyCX/muxawJQIBVc/Ix31LE5JQywnT7tAHwg
	FkeJJLHQj6q47bHMp4GOhiTaKBHbXJ+IvU7dekmVMQ==
X-Google-Smtp-Source: APXvYqwNxRXX6MojhKuxmTIkgv8yzk3NfRtB0XcnaOCwg7viPPwMQ/JTCtWNqWdiMYWGOJVL8emAQc22ws+XFOORnhM=
X-Received: by 2002:a9d:6b96:: with SMTP id b22mr8643397otq.363.1565976113121;
 Fri, 16 Aug 2019 10:21:53 -0700 (PDT)
MIME-Version: 1.0
References: <CAPcyv4g8usp8prJ+1bMtyV1xuedp5FKErBp-N8+KzR=rJ-v0QQ@mail.gmail.com>
 <20190815180325.GA4920@redhat.com> <CAPcyv4g4hzcEA=TPYVTiqpbtOoS30ahogRUttCvQAvXQbQjfnw@mail.gmail.com>
 <20190815194339.GC9253@redhat.com> <CAPcyv4jid8_=-8hBpn_Qm=c4S8BapL9B9RGT7e9uu303yH=Yqw@mail.gmail.com>
 <20190815203306.GB25517@redhat.com> <20190815204128.GI22970@mellanox.com>
 <CAPcyv4j_Mxbw+T+yXTMdkrMoS_uxg+TXXgTM_EPBJ8XfXKxytA@mail.gmail.com>
 <20190816004053.GB9929@mellanox.com> <CAPcyv4gMPVmY59aQAT64jQf9qXrACKOuV=DfVs4sNySCXJhkdA@mail.gmail.com>
 <20190816122414.GC5412@mellanox.com>
In-Reply-To: <20190816122414.GC5412@mellanox.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 16 Aug 2019 10:21:41 -0700
Message-ID: <CAPcyv4jgHF05gdRoOFZORqeOBE9Z7PhagsSD+LVnjH2dc3mrFg@mail.gmail.com>
Subject: Re: [PATCH 04/15] mm: remove the pgmap field from struct hmm_vma_walk
To: Jason Gunthorpe <jgg@mellanox.com>
Cc: Jerome Glisse <jglisse@redhat.com>, Christoph Hellwig <hch@lst.de>, Ben Skeggs <bskeggs@redhat.com>, 
	Felix Kuehling <Felix.Kuehling@amd.com>, Ralph Campbell <rcampbell@nvidia.com>, 
	"linux-mm@kvack.org" <linux-mm@kvack.org>, 
	"nouveau@lists.freedesktop.org" <nouveau@lists.freedesktop.org>, 
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>, 
	"amd-gfx@lists.freedesktop.org" <amd-gfx@lists.freedesktop.org>, 
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 16, 2019 at 5:24 AM Jason Gunthorpe <jgg@mellanox.com> wrote:
>
> On Thu, Aug 15, 2019 at 08:54:46PM -0700, Dan Williams wrote:
>
> > > However, this means we cannot do any processing of ZONE_DEVICE pages
> > > outside the driver lock, so eg, doing any DMA map that might rely on
> > > MEMORY_DEVICE_PCI_P2PDMA has to be done in the driver lock, which is
> > > a bit unfortunate.
> >
> > Wouldn't P2PDMA use page pins? Not needing to hold a lock over
> > ZONE_DEVICE page operations was one of the motivations for plumbing
> > get_dev_pagemap() with a percpu-ref.
>
> hmm_range_fault() doesn't use page pins at all, so if a ZONE_DEVICE
> page comes out of it then it needs to use another locking pattern.
>
> If I follow it all right:
>
> We can do a get_dev_pagemap inside the page_walk and touch the pgmap,
> or we can do the 'device mutex && retry' pattern and touch the pgmap
> in the driver, under that lock.
>
> However in all cases the current get_dev_pagemap()'s in the page walk
> are not necessary, and we can delete them.

Yes, as long as 'struct page' instances resulting from that lookup are
not passed outside of that lock.

