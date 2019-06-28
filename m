Return-Path: <SRS0=7Cer=U3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E4069C5B579
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 19:02:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AE95A20828
	for <linux-mm@archiver.kernel.org>; Fri, 28 Jun 2019 19:02:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AE95A20828
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5DE0F6B0003; Fri, 28 Jun 2019 15:02:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 58EDF8E0003; Fri, 28 Jun 2019 15:02:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 47D858E0002; Fri, 28 Jun 2019 15:02:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f80.google.com (mail-wm1-f80.google.com [209.85.128.80])
	by kanga.kvack.org (Postfix) with ESMTP id EE08B6B0003
	for <linux-mm@kvack.org>; Fri, 28 Jun 2019 15:02:09 -0400 (EDT)
Received: by mail-wm1-f80.google.com with SMTP id b67so2826741wmd.0
        for <linux-mm@kvack.org>; Fri, 28 Jun 2019 12:02:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=WZ3NkknDnBqS2ueiSkj21ZW3axXlay+XPFVOXe12wto=;
        b=hGN3PT1zeDufyAPjuop7E3QNcuZjxGZz5TcVFszJVx+bcTbHqBsqQyIn3FRKSa1r7O
         gWtz2OM3PpKF+nZDwwj6zcuj5rBYLMGJganYiyJn/Qj/NGEYeLe7A9fJjq67wEoySJ0c
         7gHMJwtlrq4aPz+96lxvlW3FqVqgRtoxKel87Og1+zRknSVjjJtgZvFW/zgGwgE+SVvq
         4t+DGG3AQThqlwMpKQEleUlWz1JvGLeS56R38kjhmfkt43rOEkfiAlEcgJLoNWlPRqkc
         3Q5Xsn0B6edgg5tJYi2GzpCZAZYDfiaflIxS2tzejjcOKIcJbDM2gy1X6Kte/6bInJuD
         iQfA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAVP6kewhllRSh93DlIh90SIODSCtLywOMFy83su78DnveAr/1V0
	YpsXr+/MygVnuDmIKxT7QJGXc2iyHj3Xs4U0MMtE+BH/a2+eBUeqW6pWOSyqKUmJjZcQfvciE7u
	ewMYs77crZEOWk9CrJXyTNk917uYSMurG7CWhuBFqvRWDeUKjLlSdI/VTqfuWb0Rvkg==
X-Received: by 2002:a7b:ce8a:: with SMTP id q10mr7609388wmj.109.1561748529495;
        Fri, 28 Jun 2019 12:02:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy7xMxRTGqLd3lx6+cctRrWxERBr9xMThVliZNEw/BzZF99ru29+kfDwRxWo7DD09jiRI0T
X-Received: by 2002:a7b:ce8a:: with SMTP id q10mr7609364wmj.109.1561748528840;
        Fri, 28 Jun 2019 12:02:08 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561748528; cv=none;
        d=google.com; s=arc-20160816;
        b=PophQi7B/RxG2YTzoxhlXz1VdHB6wV7vRPo9Xs8UjohnY6tvOyJlvEkQFl2gza045O
         WqYRA38W83o6ELPt/2tt6f0Sgv0WQMDax/xc12m4/+XgyUIz6zbMTyP8kgotrxW4cu9F
         cEsKRG+KDBj3JeEY5HTl77KSnJRqR56yGEBSWQ/KKirv/wZrbm8Ou4yqITy6XkxxdwKi
         Dat954SlKvO0fEZmyIzi+R8+XzrouQdM3Jcd8YRe7+cDzcZIun1FDkLwBDH1o8TwAiNW
         6XcWWs4A1WI7c9ztewY/NlMODa582aomUHXrPtOcpo6rvVtlPWS3X+jGuINzrRQdKK1b
         +iyw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=WZ3NkknDnBqS2ueiSkj21ZW3axXlay+XPFVOXe12wto=;
        b=gS+JFtYbM8JtgJYO3T+gMfBli9l6Qm9z+RIu5s1bNOeVDIiRLMW18qff306p9P72Hn
         1KEPNwhNOyXyNeb2FwInnzYTfGtae2IOzZqwbPKgBV32z8bcKWzjoKHc4bnYfSbmoBj/
         HS60tbqtJpTTmvBIO4BcW1ZXvmWujo/Agpj292LBz8yIEnJ6im6xTPbAiapBthErVp/q
         oEa4PcnLKs9HskhmA+CFRP8U5ZU0GcTMiQtFfv9GikqrR3cFaLSlHX4ARJDtqlYwBs+R
         7glQPkoAPHVPW5kEE1DLCgKpCEHa0fBXQlO+pWBViYq+vtYJmLqKPb4yY3Xaza2DBl50
         +Caw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from verein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id t127si2012194wmg.54.2019.06.28.12.02.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 28 Jun 2019 12:02:08 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id D53A7227A81; Fri, 28 Jun 2019 21:02:07 +0200 (CEST)
Date: Fri, 28 Jun 2019 21:02:07 +0200
From: Christoph Hellwig <hch@lst.de>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Christoph Hellwig <hch@lst.de>, Jason Gunthorpe <jgg@mellanox.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Ben Skeggs <bskeggs@redhat.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"nouveau@lists.freedesktop.org" <nouveau@lists.freedesktop.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 16/25] device-dax: use the dev_pagemap internal refcount
Message-ID: <20190628190207.GA9317@lst.de>
References: <20190626122724.13313-17-hch@lst.de> <20190628153827.GA5373@mellanox.com> <CAPcyv4joSiFMeYq=D08C-QZSkHz0kRpvRfseNQWrN34Rrm+S7g@mail.gmail.com> <20190628170219.GA3608@mellanox.com> <CAPcyv4ja9DVL2zuxuSup8x3VOT_dKAOS8uBQweE9R81vnYRNWg@mail.gmail.com> <CAPcyv4iWTe=vOXUqkr_CguFrFRqgA7hJSt4J0B3RpuP-Okz0Vw@mail.gmail.com> <20190628182922.GA15242@mellanox.com> <CAPcyv4g+zk9pnLcj6Xvwh-svKM+w4hxfYGikcmuoBAFGCr-HAw@mail.gmail.com> <20190628185152.GA9117@lst.de> <CAPcyv4i+b6bKhSF2+z7Wcw4OUAvb1=m289u9QF8zPwLk402JVg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4i+b6bKhSF2+z7Wcw4OUAvb1=m289u9QF8zPwLk402JVg@mail.gmail.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 28, 2019 at 11:59:19AM -0700, Dan Williams wrote:
> It's a bug that the call to put_devmap_managed_page() was gated by
> MEMORY_DEVICE_PUBLIC in release_pages(). That path is also applicable
> to MEMORY_DEVICE_FSDAX because it needs to trigger the ->page_free()
> callback to wake up wait_on_var() via fsdax_pagefree().
> 
> So I guess you could argue that the MEMORY_DEVICE_PUBLIC removal patch
> left the original bug in place. In that sense we're no worse off, but
> since we know about the bug, the fix and the patches have not been
> applied yet, why not fix it now?

The fix it now would simply be to apply Ira original patch now, but
given that we are at -rc6 is this really a good time?  And if we don't
apply it now based on the quilt based -mm worflow it just seems a lot
easier to apply it after my series.  Unless we want to include it in
the series, in which case I can do a quick rebase, we'd just need to
make sure Andrew pulls it from -mm.

