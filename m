Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B0490C169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 22:23:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 696D2218A3
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 22:23:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="DQuWhkgC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 696D2218A3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DF91E8E017C; Mon, 11 Feb 2019 17:23:39 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DA5D58E0176; Mon, 11 Feb 2019 17:23:39 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C94F48E017C; Mon, 11 Feb 2019 17:23:39 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 84DBC8E0176
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 17:23:39 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id o7so445742pfi.23
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 14:23:39 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=1WLlOJDJcxcIXG3soDmEUGpqQwzaXnBtVm7Uc05eSQI=;
        b=hwmZ18ox9Pt2GnVUShHSvWzIySPxCqoEsxNPlIG/5Wg5jjnCL/fmb6mztC4DGk+3ZY
         IhzhCT0dCKfepcutS3Pv51AYTOeOqkawr/8pTUBvFRc8RiF9g2mZFShpWd6oQuQ9bsJz
         ZbZTsU9NmfSUUN6VJWaoC+ghjo3oOFCOwo4gqfP3lWbV3gVI+fx65eys9YWW3/9TL1os
         bJd1aaPNxCLBTwYIwhiU04P/L8OKoe+N0Ipw+WRTFJv6cosEs8OsKgnerAAheb+mwmbI
         YvT72KmvMDEHQgMWO3ISpHDHvOIhS6yZIhLEOPr1QuFGWVigQfSdzqaw0tkvB/Xuomp0
         x2eQ==
X-Gm-Message-State: AHQUAuajQOU006bZH2e6D7ci1+pIMrLGNy0wrfXfnIxrK0OUg9WA0EhN
	X7hBIMN0O2YxpEmd+KE3aill+9NsU+iK0CTcVY1T3h/cO3XmS+xXcNn54tWgvWiEbSPvXVPBahI
	YRQf42GGz/y2O2zclDZsrlu5ikYEMxhBDRP1Usxx4iv+iNq4nSD39YpLR+34I+RMaNvaf+bJIXN
	4dKG6yoDo62871F2ET/R4xMXdu5h2xNpFkyNYcIePf+K98b4jSlRvnpKyN8NsnNFNjd6UPiN+MQ
	34FqRnvERU8AkqPqtniYTwm1wkT8h/xq/cgMIAA4byl5dCR19Zvr381OqYFR8kBqzqGtdKWaN60
	N163qb51oQtRnMmuHyCTPPgtDtrUI/HaMWMdOTWN9/5zdbhzC/vWiPypo2JFS1V4dtSb6Jiyjni
	c
X-Received: by 2002:a17:902:b203:: with SMTP id t3mr525827plr.243.1549923819164;
        Mon, 11 Feb 2019 14:23:39 -0800 (PST)
X-Received: by 2002:a17:902:b203:: with SMTP id t3mr525791plr.243.1549923818626;
        Mon, 11 Feb 2019 14:23:38 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549923818; cv=none;
        d=google.com; s=arc-20160816;
        b=axSjqogLYhmQ6qO0suRSjYG9dfVyRVVM64xjIcO5NsAy9GR83MXr6yIvrKfP1g3E5t
         fAPjj9ahLGfIhnvy4tMVdzIJGjLHlWA+6dubowYuLUOsKOg0uMO8XJLEM8XuJRuCU8B9
         HkDqWBtpYxUxbNdIEgACIXIQFV5HEeeATk/e1D0GrYsT2LCsJfz/ygT+fZU/y+cZY3+a
         RlPk4/N3xQFIE6lznQQIEUUUKnBuKICFY/6zfqW0+tUMz7Ha7786H1XO8x3iqv34m4cW
         UAssY0kvidRRbiadv6tOlorB5qHuo1Z66+5KS2791GtAIIvuaJBluykU8vGMuCviJKez
         MU1w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=1WLlOJDJcxcIXG3soDmEUGpqQwzaXnBtVm7Uc05eSQI=;
        b=x0vfZ3Gwbxm/VneZv9lyp8350BU+/QjEvlrXeXOymZi+Q5VTncsWndeEAiHGRFlzYP
         shSPY1GgNYn0LZa1xJkL1aemz55yYFeaEKgad5dzZgE2zS912RxmLV0FLNRZBCdiarEA
         SfsZdnAzvc8R7CmXgyutEgyBmTrTsNKl3rmIvECHnKLTZrRo2UfyTbNN9krFjKNveJjc
         S+VPBdnYKrOTIpMGPhGKRci8RWwLLgxGb4CVEORBgglbD3yysHlHwnYI6HxGk/bspNGH
         obTFe+eSNktsEA7E5nFPXCoFtSDEuKClPsgCIouCgiKFAMSxEzD2hD43LLo5FnpBJGwI
         f0Eg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=DQuWhkgC;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y27sor16922479pfi.36.2019.02.11.14.23.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Feb 2019 14:23:38 -0800 (PST)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=DQuWhkgC;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=1WLlOJDJcxcIXG3soDmEUGpqQwzaXnBtVm7Uc05eSQI=;
        b=DQuWhkgCDdMgzUqdZrbzehZBo86Fa9rjKbDUIz7mCPq+AD222ZIWTnM6kmQS8oyRpy
         LPubwTMgDAA/bsdjRIsGhu6mgUeQDqpov+bFcgQmHS042fHxaHZL8GY027k2ThHGpw/R
         xmuYJPi9flXgRJriW2XzV8jfEjvJ099LYKBJbFalttj4vPXCtJ34YZuIS+zSuPBmcADJ
         6u4G5QQZLWsjMJfNH5zzzCWXPNfR5vJIuOjm7dpli3cKkEhsmZBMbWALN81TvHrSqn0z
         khWaiTAIdL5o5BJNt/xom8HlwcvrAQ8fawFLrcpdE8HNinN/jRVc7wZAZz5sb9m1sGtT
         FGoQ==
X-Google-Smtp-Source: AHgI3IY25dSeKcjBLIFYZgY5sGbu3MRMXrBBw6lZ8FEZg89r9SGm32f9SsdhQVc1empO+bBDEtftnA==
X-Received: by 2002:a62:398d:: with SMTP id u13mr580196pfj.32.1549923818304;
        Mon, 11 Feb 2019 14:23:38 -0800 (PST)
Received: from ziepe.ca (S010614cc2056d97f.ed.shawcable.net. [174.3.196.123])
        by smtp.gmail.com with ESMTPSA id f67sm15264387pff.29.2019.02.11.14.23.35
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 11 Feb 2019 14:23:35 -0800 (PST)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1gtJzD-0003XL-8J; Mon, 11 Feb 2019 15:23:35 -0700
Date: Mon, 11 Feb 2019 15:23:35 -0700
From: Jason Gunthorpe <jgg@ziepe.ca>
To: "Weiny, Ira" <ira.weiny@intel.com>
Cc: "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Davidlohr Bueso <dave@stgolabs.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Marciniszyn, Mike" <mike.marciniszyn@intel.com>,
	"Dalessandro, Dennis" <dennis.dalessandro@intel.com>,
	Doug Ledford <dledford@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	"Williams, Dan J" <dan.j.williams@intel.com>
Subject: Re: [PATCH 0/3] Add gup fast + longterm and use it in HFI1
Message-ID: <20190211222335.GK24692@ziepe.ca>
References: <20190211201643.7599-1-ira.weiny@intel.com>
 <20190211204049.GB2771@ziepe.ca>
 <2807E5FD2F6FDA4886F6618EAC48510E79BCF04C@CRSMSX101.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2807E5FD2F6FDA4886F6618EAC48510E79BCF04C@CRSMSX101.amr.corp.intel.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 11, 2019 at 09:14:56PM +0000, Weiny, Ira wrote:
> > 
> > On Mon, Feb 11, 2019 at 12:16:40PM -0800, ira.weiny@intel.com wrote:
> > > From: Ira Weiny <ira.weiny@intel.com>
> > >
> > > NOTE: This series depends on my clean up patch to remove the write
> > > parameter from gup_fast_permitted()[1]
> > >
> > > HFI1 uses get_user_pages_fast() due to it performance advantages.
> > > Like RDMA,
> > > HFI1 pages can be held for a significant time.  But
> > > get_user_pages_fast() does not protect against mapping of FS DAX pages.
> > 
> > If HFI1 can use the _fast varient, can't all the general RDMA stuff use it too?
> > 
> > What is the guidance on when fast vs not fast should be use?
> 
> Right now it can't because it holds mmap_sem across the call.  Once
> Shiraz's patches are accepted removing the umem->hugetlb flag I
> think we can change umem.c.

Okay, that make sense, we should change it when Shiraz's patches are
merged
 
> Also, it specifies FOLL_FORCE which can't currently be specified
> with gup fast.  One idea I had was to change get_user_pages_fast()
> to use gup_flags instead of a single write flag.  But that proved to
> be a very big cosmetic change across a lot of callers so I went this
> way.

I think you should do it.. :)

Jason

