Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 96FF9C169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 22:22:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 472E8218A3
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 22:22:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="C3ya1lIk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 472E8218A3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CE6A18E017B; Mon, 11 Feb 2019 17:22:11 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C6D718E0176; Mon, 11 Feb 2019 17:22:11 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B0E7F8E017B; Mon, 11 Feb 2019 17:22:11 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6DB188E0176
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 17:22:11 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id o62so389405pga.16
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 14:22:11 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=xdkSFtkXI2U9rILZa0OLPibj9Ly6nXCAyBPxVjPqxVk=;
        b=qjiEQwENwHPSw5EYW127YZ1ps4or24cUfvXY/4sJyD1F9BcpZpqvXILHQIQPOQSYGl
         oJopxBAjGfiDLCwQIbwXw39oVG97jc5rZPpET1uG9hgfeUw+NxKA51n0Pcp6WyFsXTqb
         nSzO96hFrY7TWTQE+0ZilayHIObcxvOCZ18EyA4NEu0++myHYYz4MNRmtRcNHbRPaHIE
         hFaxwo7jMrhs66vVNCUr3AF39mGpoMtS+a6s9EZ4LmJVVwTClTUwa++iG9FdMJG4nleu
         NmL29nj6C5H45WwXghbPCG8t9KTmNCxKfugjDhNn0aOTyid+dbLOQ2SHjArKUNJdXyVw
         8/Lw==
X-Gm-Message-State: AHQUAuY1BR7jnLZTeNv+LZYOltMwML2fql7tDzCHB79JbiC6VGP9/O3g
	srp1qJl2Ztkw/q02amJgza9gFTDVvrGPQ+xtWxas0aoAOfWrSedcFMjbveoe40Nl+umqH3QlH5+
	FeUkeySXCAtJp2DyxUqvRjGR+7rX/p1qCBZIakcqIf5nIZjVGTeN6v/nR74S4AUri8PP5huIpS8
	JotKixBaBxGKMKcv/pIfY4dAa6JyHvEba61J/lhR917xBdrKrcAWCul6j3bBcwJYI0KtaoskCc7
	V1rXyHgw/Pk/NGWnP9CfrveOhSzffg93NDTRcEIIinDSr+bxjFPO8HAk7Y5h5nM8oQrtMT0FfsJ
	0CZzhqUJZl6Mq01qT7Lj94AXfjXjF0klMGJiqFtmQcZunAZCc/P4gEoNuJRKT0tJDDmUfQvxv7Y
	B
X-Received: by 2002:a17:902:24d:: with SMTP id 71mr508473plc.225.1549923731115;
        Mon, 11 Feb 2019 14:22:11 -0800 (PST)
X-Received: by 2002:a17:902:24d:: with SMTP id 71mr508440plc.225.1549923730490;
        Mon, 11 Feb 2019 14:22:10 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549923730; cv=none;
        d=google.com; s=arc-20160816;
        b=0INhvr3g20nSr5GxeS69XDHL4aBtRJj9P3wZpUyFHcpJNJwWElDMuh8Ip9q0VZLIF7
         IjbAQ6Cwzmk6uJ22O0gq0HQy6sEuJboZq0z9PXp51yWAuhEPKQ2zEraDyK/WdogFqD/6
         wuMirKTpGh1EtVGx7vlOofkM4wJYSf6OP5RKYhweSRN9ZzVN84Y0zLM/PzKsFBHtObjC
         phsUCa71CzYXY44xP9qwTZ8E7gzHOoZXnpFerAdpOKi628knc1mXdDjqGAQquQDmDrU8
         N5rTVj9tFyulen6Hou3BMtf0iHv7SwU5RKPUjDnSSg3n2YNNAvwcbotAxVkyBbl09lJo
         xdRA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=xdkSFtkXI2U9rILZa0OLPibj9Ly6nXCAyBPxVjPqxVk=;
        b=r6kDrwYh9YHQ2WmLcKeb9a6GFqAmdReUem4XheXg1v5s8mTt/BPbLPaxNelw/kg9OE
         /nYKSEYB5ObPOv3TPHAyAKeZVls2sHnQYNoO2fzgm2UqIOeyn+qTug5fboaS+USvDqf3
         QlDfSaRVc7OGeo5ivn6sjeAwATEWcrd5yF0kY4rhUYfWOLIZo4+sjQbtlZwqaSKFqE3m
         Ay1x7ofEej78EiSnMRGHTArkqjspexBKiCaCQtS3i2qps+iixSLBJ0OykXud4JVuyxtM
         klsi4VGCP/udmXiWXAYpHWKRmNvvJKDUF2GBMx0UutSreoJtdE+VO9CNROwn1YMUVelw
         aULw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=C3ya1lIk;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g16sor16422760plo.1.2019.02.11.14.22.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Feb 2019 14:22:10 -0800 (PST)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=C3ya1lIk;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=xdkSFtkXI2U9rILZa0OLPibj9Ly6nXCAyBPxVjPqxVk=;
        b=C3ya1lIkET7B0U5gcbeCUe1y0Gh1eANZFR2GVVA06FR4dychps4f5xAXwwn+RUT3KS
         rCUYYspMMPl5cOI3Rj0TobbZYURtvSEHzR9DYTIHVqrDbrimv7ulWx9vjEaVi+k2WrAr
         UK14ouUMB4UNsY/c7qiTfBE/Wz42BgP9X6oZLVX/9pisMzhgp3lhsLXGWX8ikwzdtJn0
         QWb4KFB1F4fMRDxqD8DjgaB/qW85iPXcp8oOXGNsd4NvBa6eLN3luBJQMmr8KVy0tO/+
         3hxHhSkliZu4xmI2bPusnBUX8HLKGjG63DBkCshUQIYGgALQHI1Ha7816zP8kP0qfizK
         8Rzw==
X-Google-Smtp-Source: AHgI3IYw7BALaGSULNv+3bUMQP+ikh8t2IwpZG1CncFiHzfzaPM812aozbs4PkbsejgksaVI4K2aBQ==
X-Received: by 2002:a17:902:a588:: with SMTP id az8mr536627plb.77.1549923730086;
        Mon, 11 Feb 2019 14:22:10 -0800 (PST)
Received: from ziepe.ca (S010614cc2056d97f.ed.shawcable.net. [174.3.196.123])
        by smtp.gmail.com with ESMTPSA id h15sm13896692pgl.43.2019.02.11.14.22.09
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 11 Feb 2019 14:22:09 -0800 (PST)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1gtJxo-0003WM-EN; Mon, 11 Feb 2019 15:22:08 -0700
Date: Mon, 11 Feb 2019 15:22:08 -0700
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Ira Weiny <ira.weiny@intel.com>
Cc: linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org, Daniel Borkmann <daniel@iogearbox.net>,
	netdev@vger.kernel.org,
	Mike Marciniszyn <mike.marciniszyn@intel.com>,
	Dennis Dalessandro <dennis.dalessandro@intel.com>,
	Doug Ledford <dledford@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Dan Williams <dan.j.williams@intel.com>
Subject: Re: [PATCH 0/3] Add gup fast + longterm and use it in HFI1
Message-ID: <20190211222208.GJ24692@ziepe.ca>
References: <20190211201643.7599-1-ira.weiny@intel.com>
 <20190211203417.a2c2kbmjai43flyz@linux-r8p5>
 <20190211204710.GE24692@ziepe.ca>
 <20190211214257.GA7891@iweiny-DESK2.sc.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190211214257.GA7891@iweiny-DESK2.sc.intel.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 11, 2019 at 01:42:57PM -0800, Ira Weiny wrote:
> On Mon, Feb 11, 2019 at 01:47:10PM -0700, Jason Gunthorpe wrote:
> > On Mon, Feb 11, 2019 at 12:34:17PM -0800, Davidlohr Bueso wrote:
> > > On Mon, 11 Feb 2019, ira.weiny@intel.com wrote:
> > > > Ira Weiny (3):
> > > >  mm/gup: Change "write" parameter to flags
> > > >  mm/gup: Introduce get_user_pages_fast_longterm()
> > > >  IB/HFI1: Use new get_user_pages_fast_longterm()
> > > 
> > > Out of curiosity, are you planning on having all rdma drivers
> > > use get_user_pages_fast_longterm()? Ie:
> > > 
> > > hw/mthca/mthca_memfree.c:       ret = get_user_pages_fast(uaddr & PAGE_MASK, 1, FOLL_WRITE, pages);
> > 
> > This one is certainly a mistake - this should be done with a umem.
> 
> It looks like this is mapping a page allocated by user space for a
> doorbell?!?!

Many drivers do this, the 'doorbell' is a PCI -> CPU thing of some sort

> This does not seem to be allocating memory regions.  Jason, do you
> want a patch to just convert these calls and consider it legacy
> code?

It needs to use umem like all the other drivers on this path.
Otherwise it doesn't get the page pinning logic right

There is also something else rotten with these longterm callsites,
they seem to have very different ideas how to handle RLIMIT_MEMLOCK.

ie vfio doesn't even touch pinned_vm.. and rdma is applying
RLIMIT_MEMLOCK to mm->pinned_vm, while vfio is using locked_vm.. No
idea which is right, but they should be the same, and this pattern
should probably be in core code someplace.

Jason

