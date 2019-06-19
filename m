Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 68862C31E5E
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 19:46:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 21A12214AF
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 19:46:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=intel-com.20150623.gappssmtp.com header.i=@intel-com.20150623.gappssmtp.com header.b="L+LW3co1"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 21A12214AF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A98AB8E0002; Wed, 19 Jun 2019 15:46:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A22DC8E0001; Wed, 19 Jun 2019 15:46:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 89BFE8E0002; Wed, 19 Jun 2019 15:46:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5D67F8E0001
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 15:46:14 -0400 (EDT)
Received: by mail-ot1-f69.google.com with SMTP id d62so128446otb.4
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 12:46:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=AppOhepgnEe0jjnJnZQBJyzyqCwLm69rPfFkLY+t1bc=;
        b=QeAs90CSFStdHy1E8xZRNbPRT+yRNV2VgBNtwZzjIia5zZKYjt5SSHKlddtahzLv9S
         yAopGQat9RJG5AtOjPE12fo5z4jgye0uRKykt4UEUOS84GAkD0P3/tF0cP+wks29qCHp
         IKEmweTdwoid5I61V+QFvn/E3tj5mVwbGzOZFSIcMgVQweGWl2webxJ2Hc7FSQS5DmpN
         3Hol/4R+dTSMsL+YRspstEwqrDpucxJ44GxYDMkBn5u8F74mFa9ojrMNTIkqZ0B7/l33
         f2BezytvDz27pfFDBQ4fD6ClnBA5wuELhWkVepnI9WLQA/t0x0gz/D7Jbt5EwoQWtl0w
         s2NQ==
X-Gm-Message-State: APjAAAWRfsQVJgWIK8AZQxqc1yEExYC1/QqJLhq8kaarm6MsikJbFD54
	0FnGD190HGMWS5zdJjcL0/QVAqniDsv7t67Zm9vCAQMz/GJxoOSLDNsSXEUdkDeu4sG688RgMiC
	t0xuf7u6O6svhsKBZp0YOZFuY4Qe54j4k8CBxw260E6YROpeUZPEyf67DgxNqkhmhww==
X-Received: by 2002:a05:6830:11c6:: with SMTP id v6mr2214625otq.359.1560973573983;
        Wed, 19 Jun 2019 12:46:13 -0700 (PDT)
X-Received: by 2002:a05:6830:11c6:: with SMTP id v6mr2214588otq.359.1560973573274;
        Wed, 19 Jun 2019 12:46:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560973573; cv=none;
        d=google.com; s=arc-20160816;
        b=kasWaal3AaU6cj4JY1rrSS+wyuWxxn24ixtY2UDIins7J3qqTzp1jmJloBmbzno6t/
         +GKY+CXTVFAg3bZDw5OWMN2zjODhdIbYsISAgSTDTxiPIOGV7IftYf54WJ0Q5NQ9R3/T
         rOu3/DGuSDVB5GmEi34JgDpnAn3xiSF15jdvVwNbwGrOE97RAxy2PzvQZc/qKCWDIeRi
         ZsChVGZ9EdmexmKUV54+AEbGWFE8jvpCnQMhWEeCS9kJyS2kyUJ43XX9dN7Wfc9qYtJt
         igp6zbuszmojvPrAB2PcnW0vaa+QxgVFGqdUfP0+OXGf2PwDorbXLkzyFXGfejTznfxe
         kT7Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=AppOhepgnEe0jjnJnZQBJyzyqCwLm69rPfFkLY+t1bc=;
        b=xKGA+ETHAHmnA9fnkQHjDQH2ZdjDuErpPsqBhq2r8vl5yuJRtEplqr0aYPTmiUqUnD
         XjI3nc4Qxu/IELrctl2xZNI+bxI3+2BXK13gmU+rmnB8ulEn4jYiGYIDp9B0JaCXA1lx
         lIYWNC4g5T0ThvSPsbTFrTVHM+AHLmD4tUDDsA/46nB+13TdpXzBx9S8OXVVidN+P36n
         HTQrNTjjFatrqUiQF+IUBN54cYs26rU6zyYPzJmLhJrOkFjfbHbfUeu0ETlSr4NFCTN+
         jNrcV2jCrh7ggaXMUCz3ho7SAoSPh2AEEkmsPbcuOaz1pROxx9UtxLigAp6UfSCfy2Mn
         xr3w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=L+LW3co1;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i7sor9536872oto.26.2019.06.19.12.46.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 19 Jun 2019 12:46:13 -0700 (PDT)
Received-SPF: pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@intel-com.20150623.gappssmtp.com header.s=20150623 header.b=L+LW3co1;
       spf=pass (google.com: domain of dan.j.williams@intel.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=dan.j.williams@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=intel-com.20150623.gappssmtp.com; s=20150623;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=AppOhepgnEe0jjnJnZQBJyzyqCwLm69rPfFkLY+t1bc=;
        b=L+LW3co1OBHWplV01UpK1fvt6NIcRF2qR2+gyrISeEZDbLPi91YZXqNIJExJQhxjVL
         7NO7u5O4wqUQFCjZA8X/xN5IC6nTONNL0PLEmadz1t01bknVW+LPFjhIpUDlZICWj1OK
         Gog3pb+AQtERVqv6j7fTaoTVYFpk5W1Hfef0DgmAjMPes0MNZ9hclPMHOd3R6z/1niZy
         xhltfPQTbipOo4AOyWvfdtdcgObLiRuElMk7blxcxcA8+NrVrohUYIrXM1xWntr04dh1
         fdyvcy8a9IUZO0qDkJUM7+nBLab/Ub+ZVWPgR39zFgOFrotnlWhaK61bEldeFuweA1TX
         hgpA==
X-Google-Smtp-Source: APXvYqyF4/fQjVQSHjLx0TTlLSRvNfoC1XWgfZBLjCA5t1eNPRU75djqD3lZLhJzoRPj37ekmpc9LL5nqKSkBxWsIsE=
X-Received: by 2002:a9d:470d:: with SMTP id a13mr36193657otf.126.1560973572970;
 Wed, 19 Jun 2019 12:46:12 -0700 (PDT)
MIME-Version: 1.0
References: <20190613094326.24093-1-hch@lst.de> <20190613094326.24093-19-hch@lst.de>
 <20190613194430.GY22062@mellanox.com> <a27251ad-a152-f84d-139d-e1a3bf01c153@nvidia.com>
 <20190613195819.GA22062@mellanox.com> <20190614004314.GD783@iweiny-DESK2.sc.intel.com>
 <d2b77ea1-7b27-e37d-c248-267a57441374@nvidia.com> <20190619192719.GO9374@mellanox.com>
In-Reply-To: <20190619192719.GO9374@mellanox.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 19 Jun 2019 12:46:01 -0700
Message-ID: <CAPcyv4j+zk_5WvFXbUbQ7bWisjWSwzwLsXide1AuVL4kLX8iyQ@mail.gmail.com>
Subject: Re: [PATCH 18/22] mm: mark DEVICE_PUBLIC as broken
To: Jason Gunthorpe <jgg@mellanox.com>
Cc: John Hubbard <jhubbard@nvidia.com>, Ralph Campbell <rcampbell@nvidia.com>, 
	"linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, 
	"nouveau@lists.freedesktop.org" <nouveau@lists.freedesktop.org>, 
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, 
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, 
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	Ben Skeggs <bskeggs@redhat.com>, 
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>, Christoph Hellwig <hch@lst.de>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 19, 2019 at 12:42 PM Jason Gunthorpe <jgg@mellanox.com> wrote:
>
> On Thu, Jun 13, 2019 at 06:23:04PM -0700, John Hubbard wrote:
> > On 6/13/19 5:43 PM, Ira Weiny wrote:
> > > On Thu, Jun 13, 2019 at 07:58:29PM +0000, Jason Gunthorpe wrote:
> > >> On Thu, Jun 13, 2019 at 12:53:02PM -0700, Ralph Campbell wrote:
> > >>>
> > ...
> > >> Hum, so the only thing this config does is short circuit here:
> > >>
> > >> static inline bool is_device_public_page(const struct page *page)
> > >> {
> > >>         return IS_ENABLED(CONFIG_DEV_PAGEMAP_OPS) &&
> > >>                 IS_ENABLED(CONFIG_DEVICE_PUBLIC) &&
> > >>                 is_zone_device_page(page) &&
> > >>                 page->pgmap->type == MEMORY_DEVICE_PUBLIC;
> > >> }
> > >>
> > >> Which is called all over the place..
> > >
> > > <sigh>  yes but the earlier patch:
> > >
> > > [PATCH 03/22] mm: remove hmm_devmem_add_resource
> > >
> > > Removes the only place type is set to MEMORY_DEVICE_PUBLIC.
> > >
> > > So I think it is ok.  Frankly I was wondering if we should remove the public
> > > type altogether but conceptually it seems ok.  But I don't see any users of it
> > > so...  should we get rid of it in the code rather than turning the config off?
> > >
> > > Ira
> >
> > That seems reasonable. I recall that the hope was for those IBM Power 9
> > systems to use _PUBLIC, as they have hardware-based coherent device (GPU)
> > memory, and so the memory really is visible to the CPU. And the IBM team
> > was thinking of taking advantage of it. But I haven't seen anything on
> > that front for a while.
>
> Does anyone know who those people are and can we encourage them to
> send some patches? :)

I expect marking it CONFIG_BROKEN with the threat of deleting it if no
patches show up *is* the encouragement.

