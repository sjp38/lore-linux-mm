Return-Path: <SRS0=EPqI=U2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2D09EC48BD7
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 08:51:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C1038206E0
	for <linux-mm@archiver.kernel.org>; Thu, 27 Jun 2019 08:51:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C1038206E0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 727546B0006; Thu, 27 Jun 2019 04:51:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6B0188E0003; Thu, 27 Jun 2019 04:51:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5774B8E0002; Thu, 27 Jun 2019 04:51:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1E4CF6B0006
	for <linux-mm@kvack.org>; Thu, 27 Jun 2019 04:51:20 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id e8so798848wrw.15
        for <linux-mm@kvack.org>; Thu, 27 Jun 2019 01:51:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=0FYL/C8LMXop2iYPBLRdJtUCS8499koIOoQN5tLFlOs=;
        b=gCBfXtBY7uul/M7UbA5Uemm66zr7fyIWCWyezRbgeAQNxyV3gLeote4DVTcNDac/H2
         /xVeCDdhomrwf5YxBPq5Kx3mvFX8PGpifuj092CzsBA6W1OgY4VKk4Yn6XMhVCYvlj+W
         qrXXu9iIoOUom/t7x6dY+zIt9bBZat7aQ2Kd3dwxvGlrcw/asVIbWIKgKYpwo7yFsq/7
         gfo6AlCaTeDi4odIVbCffWvBMz0/tTq/Jq5U/1G0lX71l4RYM/5taB8UF9KrhqWSVA8D
         2wDmsIfcofpT2DEoJ8ETupBOpeKeNWrA49WgenZHMbvpb0c1YRLWxzCWU+B9vGzAfnQ8
         ivgw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAXyVnbxAdPRITg+ezFurlXFh8xDl8GvMJSLh1IiTHXwBOf7A0cG
	rB25YJSipItIme/1QqNIW/T6OCNnVEEXQXHEhXLeZmX4cY80XV9HxwMxL4tN+52hMjkj2m7ryjd
	GgAHA1e56CXtX1KMffUmF9P0YJRWwQcSoiEPxurGuVanK+EWFLSlxMtO4Od4eRO0Eag==
X-Received: by 2002:adf:e2cb:: with SMTP id d11mr2254714wrj.66.1561625479658;
        Thu, 27 Jun 2019 01:51:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwydJ69ncubKVYURk8Eu3Cp3ekE7ga0rA0HNQ0MwK8Jt0+s4rJ1A1n7O560v3ZOnMV8EvE8
X-Received: by 2002:adf:e2cb:: with SMTP id d11mr2254641wrj.66.1561625478854;
        Thu, 27 Jun 2019 01:51:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561625478; cv=none;
        d=google.com; s=arc-20160816;
        b=QExBgNtjJq1IPOaP0c/yQetfu6ZiAMfo9hMn4c14hKa2FN7+861ep/PfLwwPnIiEPw
         Ksg5r1ffOhaKfn46CsinsLN//1AxzS0Gu50Z2vhxQoW7l1g8DteMO9BD0+8cyjwLPIV7
         rurJ5vMHZkV5VV91PdXESg9vjb4JyWNkJbtbldFN36D2vkORjZXx0UTmq4CX6T5FdVd4
         5ZuCHPgHpub1jPWzOL2VRUH82uh5TBUucRh1luTpOzf40gNG2JZqo8TmljO9fYH4pN34
         goCu1XMiXXazAMu99SInloNgR+Lwb2KXgU/6znvQ+CDLSVhNzdQSBC6uzEn9Oh5F9ufR
         Q0GQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=0FYL/C8LMXop2iYPBLRdJtUCS8499koIOoQN5tLFlOs=;
        b=ZQl7hNEdvtEgLQ7QHBPqF2SNRejXFxG/y1+i5b36sYggLZq6l2T6z48UmRpjqzZ5Yn
         P5ZBvl8sModi1rZXJ7s0nvCHIBpHgVWXVU6V5U/A5bFqXL+Ags/LbyvyiRLK96DJ3gXs
         JDeRa83YFYhcEEE8I/G2jiJ0jMd1uzDT0bZ+eXUMAZLoZRXH56ThgtXXIkKP3/O0dS1q
         Iyw/Ys69Lw+poYm33QUATXLAdvTkjYAxMxPGT5iRS3OtACqYUasH9frX2mM3Rc8jWTVJ
         6gBaptho4lmDtFCg4kAALp5Go/aqTOrFRpaAw5mFvqtfmLi+cuGo8PNaQuq639nt3wBf
         AbdQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id p16si1412036wrj.155.2019.06.27.01.51.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Jun 2019 01:51:18 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id 742B868B20; Thu, 27 Jun 2019 10:50:47 +0200 (CEST)
Date: Thu, 27 Jun 2019 10:50:47 +0200
From: Christoph Hellwig <hch@lst.de>
To: Ira Weiny <ira.weiny@intel.com>
Cc: Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>, Ben Skeggs <bskeggs@redhat.com>,
	linux-nvdimm@lists.01.org, linux-pci@vger.kernel.org,
	linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org,
	linux-mm@kvack.org, nouveau@lists.freedesktop.org
Subject: Re: [PATCH 11/25] memremap: lift the devmap_enable manipulation
 into devm_memremap_pages
Message-ID: <20190627085047.GA11420@lst.de>
References: <20190626122724.13313-1-hch@lst.de> <20190626122724.13313-12-hch@lst.de> <20190626190445.GE4605@iweiny-DESK2.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190626190445.GE4605@iweiny-DESK2.sc.intel.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 26, 2019 at 12:04:46PM -0700, Ira Weiny wrote:
> > +static int devmap_managed_enable_get(struct device *dev, struct dev_pagemap *pgmap)
> > +{
> > +	if (!pgmap->ops->page_free) {
> 
> NIT: later on you add the check for pgmap->ops...  it should probably be here.
> 
> But not sure that bisection will be an issue here.

At this point we do not allow a NULL ops pointer.  That only becomes
a valid option one the internal refcount is added.  Until then a NULL
->ops pointer leads to an error return from devm_memremap_pages.

