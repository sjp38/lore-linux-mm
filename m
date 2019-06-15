Return-Path: <SRS0=cZWw=UO=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B47D6C31E47
	for <linux-mm@archiver.kernel.org>; Sat, 15 Jun 2019 08:34:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 791062070B
	for <linux-mm@archiver.kernel.org>; Sat, 15 Jun 2019 08:34:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 791062070B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E2F756B0006; Sat, 15 Jun 2019 04:34:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DB80E6B0007; Sat, 15 Jun 2019 04:34:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C805C8E0001; Sat, 15 Jun 2019 04:34:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 777446B0006
	for <linux-mm@kvack.org>; Sat, 15 Jun 2019 04:34:26 -0400 (EDT)
Received: by mail-wm1-f72.google.com with SMTP id y80so987476wmc.6
        for <linux-mm@kvack.org>; Sat, 15 Jun 2019 01:34:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=mR7PxNzd5bP66FhVZHZ5KOQNeolUowFMkemyz6yQM7g=;
        b=HZDKgrn7S4x0JKu+PuQBBu0+hfORw/W+/mSZSgzrsR/CQctACky4jcSqr6nHlcdNTx
         dSl6rcjqANBDKZlpB2b5Y21VExkAltCJ0OPZSjnFJCx4faclD7NjmN3v2B9NUYZ4GjUT
         oT2svHKwhH5qBXCKXeHP2YypN8PQady9oIT0hKnM7LLhANXwnLjQJMGfESntLa1bW8m3
         CKkt5BAgCi/k0H+CrE4muGGMMRksMS0HGjs9DTmae+aiNUyKX9FK3CHxul0kiWa/Hjh4
         BiAJQX7esco2t4YrusDCB7QY5CllEJAZFh0F6+4coenwxYIIVl+xvQ7c5se4mavFG08D
         /azA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAWxfMrQkZnBEmUVvVn3xKahWqGYOpIO+1Po/eAWFUUkPPTvqnXt
	Sd1miB4bxq4K+oMaorq7h95W8NbPZKssoThFCfniPd8wNzbwKATjL07rguQLr1Yqz1nYI2ZvVVt
	wgRI7kUBM32j1gwJa1IvFjyo/KwQVfhVr3JaL5rirxkLgWZFWlFSL5pPYivrXgdBUKw==
X-Received: by 2002:adf:efc8:: with SMTP id i8mr40341859wrp.220.1560587666039;
        Sat, 15 Jun 2019 01:34:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzdkyesfwUN5mCZ+qEcsujUmkW1dHYJUxD1ZNjqJ1lrtsXWJSvf64Y713BQ/ehIRUuFRvOX
X-Received: by 2002:adf:efc8:: with SMTP id i8mr40341820wrp.220.1560587665268;
        Sat, 15 Jun 2019 01:34:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560587665; cv=none;
        d=google.com; s=arc-20160816;
        b=fLXgD7QUGbjN1+UQ3qFiVDZxlYQJS/Q1i1C07MXvnqC5DORufgH0JXhyb11n2As16S
         FxUG2zWFsc254s3DVgIkgwN1GUeHRevbgP7rd/0+mRfYde0dhY8a/tbat07lrGDr45Ah
         IkXSGGCIppdSbe6Z0r13aERhXp6pTIgOO4AxYR+SGxeU63r5Y/kGNdWbOSNTnC1fM3MH
         pfXrzsH5nhrEhYUgp1UybZxgObgF0k6ultZVplI+HF9OaB0E3c70Myz1brJPAdD/X6Op
         +RJxKJhV9JIu0HQtPawtvg9sS6BG6jtJsOT8lXVg6MjEPtodTYJKsgwVOcW+pc4N4Ct+
         sKWg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=mR7PxNzd5bP66FhVZHZ5KOQNeolUowFMkemyz6yQM7g=;
        b=LKkTTqZfhC689lNsINnBJ9dEpVdweFMHMzlRz6ruS9hUUIYHIve8v7k8q26m7gvAHb
         a6W5I9HXHoSR7P0fEFoleP2xMGWGTAlOOA5oM+vw6zUDoiSHhccOn4MEFQHImTI23VK1
         Zaoz2Nu6Bhk7u4tdO6HWvy9sIWv/65q0lMhotrKNDH7AZFY/yBekxTSeltjgRDcqyIEn
         Lp+ogozTpMq9BpKMi4lCsqpTx1EHdaQRi8Ap2bbgwUyDO7BnGYIZvCjlYWhVJ/v4krGF
         2jYx04QHcsyJiuAiHSiJFnn7aKclvguncgqooJYCzY8BzCRK8Q2o4kct1Q41jy8G5l+m
         5Q2g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id z133si719667wmb.21.2019.06.15.01.34.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 15 Jun 2019 01:34:25 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by newverein.lst.de (Postfix, from userid 2407)
	id 31A9C68AFE; Sat, 15 Jun 2019 10:33:57 +0200 (CEST)
Date: Sat, 15 Jun 2019 10:33:56 +0200
From: Christoph Hellwig <hch@lst.de>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Christoph Hellwig <hch@lst.de>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>, Ben Skeggs <bskeggs@redhat.com>,
	Linux MM <linux-mm@kvack.org>, nouveau@lists.freedesktop.org,
	Maling list - DRI developers <dri-devel@lists.freedesktop.org>,
	linux-nvdimm <linux-nvdimm@lists.01.org>, linux-pci@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: Re: dev_pagemap related cleanups
Message-ID: <20190615083356.GB23406@lst.de>
References: <20190613094326.24093-1-hch@lst.de> <CAPcyv4jBdwYaiVwkhy6kP78OBAs+vJme1UTm47dX4Eq_5=JgSg@mail.gmail.com> <20190614061333.GC7246@lst.de> <CAPcyv4jmk6OBpXkuwjMn0Ovtv__2LBNMyEOWx9j5LWvWnr8f_A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4jmk6OBpXkuwjMn0Ovtv__2LBNMyEOWx9j5LWvWnr8f_A@mail.gmail.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 14, 2019 at 06:14:45PM -0700, Dan Williams wrote:
> On Thu, Jun 13, 2019 at 11:14 PM Christoph Hellwig <hch@lst.de> wrote:
> >
> > On Thu, Jun 13, 2019 at 11:27:39AM -0700, Dan Williams wrote:
> > > It also turns out the nvdimm unit tests crash with this signature on
> > > that branch where base v5.2-rc3 passes:
> >
> > How do you run that test?
> 
> This is the unit test suite that gets kicked off by running "make
> check" from the ndctl source repository. In this case it requires the
> nfit_test set of modules to create a fake nvdimm environment.
> 
> The setup instructions are in the README, but feel free to send me
> branches and I can kick off a test. One of these we'll get around to
> making it automated for patch submissions to the linux-nvdimm mailing
> list.

Oh, now I remember, and that was the bummer as anything requiring modules
just does not fit at all into my normal test flows that just inject
kernel images and use otherwise static images.

