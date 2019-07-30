Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DAD05C433FF
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 13:14:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A3572206E0
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 13:14:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A3572206E0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 51A088E0003; Tue, 30 Jul 2019 09:14:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4A1DD8E0001; Tue, 30 Jul 2019 09:14:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 343538E0003; Tue, 30 Jul 2019 09:14:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id DB7448E0001
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 09:14:33 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id t9so32012756wrx.9
        for <linux-mm@kvack.org>; Tue, 30 Jul 2019 06:14:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=O39tljEUZUIgLTp/02suhA3FyrkOZ6vkQIrqsfQFUwY=;
        b=L5tAeMa38ZKbyMIqG8GyA3B0utT38UDdpgJ8yqkE3Bc6RP3tsCtZyNo45z1fjs14mB
         y3/e30ZkfSRWQ5BrwyD3X8/SRs/+vOP8AfZtTK64XPqMzzfRbA4GgNwl4zbI6Rp9eDnW
         S7d8NutpCZgjCF3JX59s4uELFBgIogEj8ZZ3lEa/BCxbHqneE+wugji8fywW7E/BCkyi
         IdjskEl3S8PPk2Hx4cKp+BVd4B4qrSwOkexCMxvp8fMeZLyeYLVUACnfCyZmL1txw/uF
         eVMBwylXyWuijRuvrj7MejDhgdidkTHwzCyrIreJg0lH9gsQs7Xg6Ba3FZ0HecBlQ1jo
         dB/A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
X-Gm-Message-State: APjAAAWUkUGAxfkqRWmuVuJ8y04WzqVhhStEXIr25ZkRuFYMyqx3arY5
	PeVjnha9D/uhpBmAa23H6O31kygTi7yfLio/IQYfEPr54wWnQWnNrPEzMAr/GqY6MROZYWeFXZp
	ZVlZIbQRAtw0mvPLxPEZ9NxuaY3uk0lz0RTpPHwbYsG8ULu+xAC9555H0YJrhIzTlXw==
X-Received: by 2002:adf:de10:: with SMTP id b16mr92995844wrm.296.1564492473477;
        Tue, 30 Jul 2019 06:14:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyRDN0b2uldMHFto4ririFEionc0rep1t3RczSdqjehHgS/kQjB6DZHzcoLg8O13Hhwq//3
X-Received: by 2002:adf:de10:: with SMTP id b16mr92995796wrm.296.1564492472752;
        Tue, 30 Jul 2019 06:14:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564492472; cv=none;
        d=google.com; s=arc-20160816;
        b=CG4ZO58r5X6DDktb7qvDbnstF7fNZbbRoxv6ScL8w9MuSSCy/forTzvA/wFwZwc2WY
         dLYXZUg/s30cxQ7wMFvU/CtXH0DGOnM3Qn0KHWA4vp/do/GxR83WTiNX5TWOa2RQgKOP
         6uIw9Qr2digE7cnYOb0EH8Xmye6BbT+hOF7vBm7UsqrbVNB/y6NRg5oqLYsf9Ulc1Ztk
         SqC2lgv8hQx4jd4vkwyrq0O3tFtrrrBvMyU6MtOXiCynyzohXmot7kzLDop+hTN20nXE
         HSU7rF3PpfsjWbl3wjXoN2BnDkjTybMz0MpuTcY1MmtiZhTOaWkgFJQ9ZygLSv5srw2s
         4zhw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=O39tljEUZUIgLTp/02suhA3FyrkOZ6vkQIrqsfQFUwY=;
        b=dCRMzCksnEGn/KQG/7XrVWZkdPsw+1tjj/vpdW6vEDIRLF7Rt3E8cVFdEyR8j7BE+M
         icF3D+p7sz+in+CXHR/UFkiuX7GXRi8CW5vHBvgzq28eyKxkAIzoYvcKzggYSLNrt6jW
         CdqdwtqAOUZTrtKBb0NFGEWVwH1cFPTDAd4l+9JFEcv8JRItNlrbJNZMie9OppfoLOwe
         Jy9GqcKx4S4Dh3BHisDiOfgFF04JMe4civgy34AEg5WS9NYE9jp58g4sB041OTKyUbzg
         TdjBgwqU0WHuA3iOulc1OX10GggBL7bQBQnUkIeQdwUWoZGP7oeEZph1rNlVTGqPElXj
         0onA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: from verein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id i3si43473236wrr.81.2019.07.30.06.14.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Jul 2019 06:14:32 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) client-ip=213.95.11.211;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of hch@lst.de designates 213.95.11.211 as permitted sender) smtp.mailfrom=hch@lst.de
Received: by verein.lst.de (Postfix, from userid 2407)
	id 9486D68AFE; Tue, 30 Jul 2019 15:14:30 +0200 (CEST)
Date: Tue, 30 Jul 2019 15:14:30 +0200
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
Message-ID: <20190730131430.GC4566@lst.de>
References: <20190730055203.28467-1-hch@lst.de> <20190730055203.28467-8-hch@lst.de> <20190730125512.GF24038@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190730125512.GF24038@mellanox.com>
User-Agent: Mutt/1.5.17 (2007-11-01)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 30, 2019 at 12:55:17PM +0000, Jason Gunthorpe wrote:
> I suspect this was added for the ODP conversion that does use both
> page sizes. I think the ODP code for this is kind of broken, but I
> haven't delved into that..
> 
> The challenge is that the driver needs to know what page size to
> configure the hardware before it does any range stuff.
> 
> The other challenge is that the HW is configured to do only one page
> size, and if the underlying CPU page side changes it goes south.
> 
> What I would prefer is if the driver could somehow dynamically adjust
> the the page size after each dma map, but I don't know if ODP HW can
> do that.
> 
> Since this is all driving toward making ODP use this maybe we should
> keep this API? 
> 
> I'm not sure I can loose the crappy huge page support in ODP.

The problem is that I see no way how to use the current API.  To know
the huge page size you need to have the vma, and the current API
doesn't require a vma to be passed in.

That's why I suggested an api where we pass in a flag that huge pages
are ok into hmm_range_fault, and it then could pass the shift out, and
limits itself to a single vma (which it normally doesn't, that is an
additional complication).  But all this seems really awkward in terms
of an API still.  AFAIK ODP is only used by mlx5, and mlx5 unlike other
IB HCAs can use scatterlist style MRs with variable length per entry,
so even if we pass multiple pages per entry from hmm it could coalesce
them.  The best API for mlx4 would of course be to pass a biovec-style
variable length structure that hmm_fault could fill out, but that would
be a major restructure.

