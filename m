Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6BE8AC19759
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 06:49:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1B4E1214DA
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 06:49:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1B4E1214DA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9D8F18E0006; Thu,  1 Aug 2019 02:49:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9638B8E0001; Thu,  1 Aug 2019 02:49:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 804858E0006; Thu,  1 Aug 2019 02:49:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2F1BC8E0001
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 02:49:18 -0400 (EDT)
Received: by mail-wm1-f70.google.com with SMTP id d65so16957654wmd.3
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 23:49:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=8ZweC44Y9oqtOXhFfCaZq4sKhgjTa0P0VPbujWn/PKU=;
        b=tjjTRTQaPZFxrMi4SIhFrfngWPilyxfSy2HCzfVPM/pgapYSoy9moax8zfiqZdMD3k
         rj85RUdzjwrc/JGk8IHni41uKnRD799rTPMmLtuoHDuWazfzcRSkl4atYcm0gUHZX74s
         7uJToPvkxS2mmrxjjz7ZnczEQpxj89sEpFjwM5GAbSyVNlXqQlIRbozcTon0SIUXpqaD
         cT7l2crsWNFrY/8FBMbQB4wXr2y1oEztf+gTV+m6fNreVgKzocOyNt0L2E0cSzM73joc
         ErV8VA7/VSgA8St1K1Yt0FWjtjl+jVuibLsLR9/i21PK702zCFfABb+lsdPHpLFd2ci3
         il5A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAXHucoISwXks77L+1AHsmPO25iJkwQGmfqWYZ5b6HQcPDWAWNhi
	I5ZnfzAb1bHa8nv17k1dlWY7H0sBLJ169CxK+iu22lCjiBQRTJSikLdw//HDi2L10Wk05viOZzu
	Hfv5XEK92i4APQpm0oWCFIJIct1KrNzSMq6qE1f3j+uCJHRQE1tzWEvDPONtyGhrTFw==
X-Received: by 2002:a05:6000:4b:: with SMTP id k11mr35477973wrx.82.1564642157678;
        Wed, 31 Jul 2019 23:49:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxjzu31AWXI+glvlcmDIE0Z6P++sd/brOCW9g+p3ECQGg0OQCTbWia2d/t/j1OgYwlbf10b
X-Received: by 2002:a05:6000:4b:: with SMTP id k11mr35477935wrx.82.1564642156915;
        Wed, 31 Jul 2019 23:49:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564642156; cv=none;
        d=google.com; s=arc-20160816;
        b=OetjRTUN0SQON0sqgETWYK+4fLAJP9QwpjA6yLeSvMH961UDX8Mhwvau4xDFjANf7M
         x33WnPEJbHESGxEJj+wTU2jl9jvxms0De4RdlrHomgIdLhYOH3uFZSgJxvTxN0spTLOV
         rN7c3zKouwt5PZfXQ+BW4wUFMw8gCGkgMUPShVUvO2hM9+d+ZruVWc9skYDereDuOKeh
         XDn+BUT/ozOQLX6Qu9ovt6gvkC9JxWz5U2i3N1t1yoeK9CAboPOxptVCEym8d/pJ21hV
         aSIg/KwcQ5HcwDOZY6EmyzFzRLxBC+i8En09pIEn0FVmZSk2hSZ6f6Wn5i46sP5fneCs
         o00w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=8ZweC44Y9oqtOXhFfCaZq4sKhgjTa0P0VPbujWn/PKU=;
        b=a67fawFtWNJc4mMy8ZrVxoBPuivsNc9S4EiSfwiqJ6+5B+xsiRp5vkjiuEs3IZw90L
         /C8uJ8VmA3csQtgioFUZoOo7VNoTBqCsjXAASYzp9RWnMN+UdJezs64xazjQ1bh4kYb6
         Z65RPyjxxCJ5WxdE2QlsJvxyvgUC4wbX77Pl3HeyLDIuirBsPTH2NqBD51WcTmheZjA+
         0dAWO2RVuY7Shwwh0jErHhHfNdQixV+ruiVLS4emXKG7wr8pUquRNPnb85m8kzbpiU6i
         wXy7yroExP5uRJ/bpC3gRnJXTaNnPTxcgyElU3SzPFKxpBIC20UguzuRF6NQACIzRFQ/
         oRAg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from verein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id a21si52129477wmg.184.2019.07.31.23.49.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 23:49:16 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id A602568B05; Thu,  1 Aug 2019 08:49:14 +0200 (CEST)
Date: Thu, 1 Aug 2019 08:49:14 +0200
From: Christoph Hellwig <hch@lst.de>
To: Jason Gunthorpe <jgg@mellanox.com>
Cc: Christoph Hellwig <hch@lst.de>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Ben Skeggs <bskeggs@redhat.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"nouveau@lists.freedesktop.org" <nouveau@lists.freedesktop.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"amd-gfx@lists.freedesktop.org" <amd-gfx@lists.freedesktop.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 07/13] mm: remove the page_shift member from struct
 hmm_range
Message-ID: <20190801064914.GA15404@lst.de>
References: <20190730055203.28467-1-hch@lst.de> <20190730055203.28467-8-hch@lst.de> <20190730125512.GF24038@mellanox.com> <20190730131430.GC4566@lst.de> <20190730175011.GL24038@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190730175011.GL24038@mellanox.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 30, 2019 at 05:50:16PM +0000, Jason Gunthorpe wrote:
> The way ODP seems to work is once in hugetlb mode the dma addresses
> must give huge pages or the page fault will be failed. I think that is
> a terrible design, but this is how the driver is ..
> 
> So, from this HMM perspective if the caller asked for huge pages then
> the results have to be all huge pages or a hard failure.

Which isn't how the page_shift member works at moment.  It still
allows non-hugetlb mappings even with the member.

> It is not negotiated as an optimization like you are thinking.
> 
> [note, I haven't yet checked carefully how this works in ODP, every
>  time I look at parts of it the thing seems crazy]

This seems pretty crazy.  Especially as hugetlb use in applications
seems to fade in favour of THP, for which this ODP scheme does not seem
to work at all.

> > The best API for mlx4 would of course be to pass a biovec-style
> > variable length structure that hmm_fault could fill out, but that would
> > be a major restructure.
> 
> It would work, but the driver has to expand that into a page list
> right awayhow.
> 
> We can't even dma map the biovec with today's dma API as it needs the
> ability to remap on a page granularity.

We can do dma_map_page loops over each biovec entry pretty trivially,
and that won't be any worse than the current loop over each page in
the hmm dma helpers.  Once I get around the work to have a better
API for iommu mappings for bio_vecs we could coalesce it similar to
how we do it with scatterlist (but without all the mess of a new
structure).  That work is going to take a little longer through, as
it needs the amd and intell iommu drivers to be convered to dma-iommu
which isn't making progress as far as I hoped.

Let me know if you want to keep this code for now despite the issues,
or if we'd rather reimplement it once you've made sense of the ODP
code.

