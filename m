Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 343F3C04AB5
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 14:53:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DF3552083D
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 14:53:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="YyM3d9F8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DF3552083D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 878786B0279; Thu,  6 Jun 2019 10:53:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 828FB6B027A; Thu,  6 Jun 2019 10:53:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 718126B027B; Thu,  6 Jun 2019 10:53:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4E6DA6B0279
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 10:53:05 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id z16so2260458qto.10
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 07:53:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=Rwk3g2mjO7u8AyfAS8Q2YGcDDqcuXwzQCBazZp8dMOI=;
        b=mgvlFYSSWP/1PQAko2KMksrlOL/4W5DaLXh6A38vZ23lRBXn5zvqB6c/4kvBllZCNh
         sGClxDtnoNquCwO/sGsjQntFKPmYR6DSCcVF66P9Ybfyibw+UISzn0Q+REFIg2LGYifN
         dK14QRLxn/KZxYc+1ovx7FybRYjPJlUP8JVC2ynpzATXbOMHdAD4qehcro1mWsjeD4HL
         PkujbxiLG9GbfQa+HxEPgg3BIXme9+Dk9OUQhRBgSWRRZEhEebZethupxhNGL8M409oT
         vOx6VwuKhRF+kPbzeFt4BNAfU3F+UP1ikuv7OzApRFwYtsLXQW1k9Wnu6h+u/+owHIWT
         6SdQ==
X-Gm-Message-State: APjAAAVBk808yYrYIE9qAfkgIulLxgRvVdJuO9bZTmEzatI74gjgc7KJ
	sjVh8yNhOEnSLUM8tvIpfNxGnu7ceKYCiVBZ5FwkhsRhK/ONrhjTFhTo6QFlnJ9frU0Dl8tBmVC
	3KTIkTHoUCw4O0PE6CPD+xFsnWAS4VVpdgxZbnrukq7MDNHTyCjdMZ4zYGHsRqd+NbQ==
X-Received: by 2002:a05:620a:12ef:: with SMTP id f15mr20505299qkl.340.1559832785107;
        Thu, 06 Jun 2019 07:53:05 -0700 (PDT)
X-Received: by 2002:a05:620a:12ef:: with SMTP id f15mr20505256qkl.340.1559832784603;
        Thu, 06 Jun 2019 07:53:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559832784; cv=none;
        d=google.com; s=arc-20160816;
        b=Ls3+8sppp55od+vb0lXthrVX1d9joagMI1sRK26Ne6Ty6+IHNgbIdAl2B/ylqCdpQb
         MPpii7zAlydin3TJzluw4mT3jM345/eJWnkP6NxgtPgJImEgF4PIyinOW4WQWMEWydzX
         9CW3dflV07zro5kyhHEchPBUqz7OAfhUn7UOwkSjS3DReqsZIWmDidJGVR0FFhW60Y8m
         wZmSzMQYctyUorv8YSO4SjpF8hlAwBFGd8jfvFmvduQ8oU9y5dt68HEGwsgk+pR0bKnv
         PQDSsFGFwzh+OxwRD79uvB2Hbb2IdLhH8ErneWY6Gjtnx63R3CD2aHO1lfAlwSI49kBp
         TvGA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=Rwk3g2mjO7u8AyfAS8Q2YGcDDqcuXwzQCBazZp8dMOI=;
        b=m6qcIFbghTcpST40yinut98kufQXaaqugjg/hyuNLAlOWsb40CoKE8vAlgPYxOHPs8
         9EV7xOKhfScXGs94hfTUYqxP0UxIZ98zpg59vpHbYd/OApmAzymyGR3fGTHiJ7QhUmPZ
         xeCUqSAXfXjE90Gme9fRYEYm2//iY6q0iLe2/6NjEwCocE6GDE+LeE29Xu6+wPpqzNHW
         mgqx5np05PbBYzajgJst8hdBHW+etHHb/ZoJR310TEluZ7IzYVdDV4lzjX2/f6t8ndNp
         fdZVaN2DVhldK7uasApq0QV7QB0iQkfrEkfpmPk85bSNRGPDqRjk/Bz5Cd9WPX8m7ERn
         iWGw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=YyM3d9F8;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l51sor1601797qvc.55.2019.06.06.07.53.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 06 Jun 2019 07:53:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=YyM3d9F8;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=Rwk3g2mjO7u8AyfAS8Q2YGcDDqcuXwzQCBazZp8dMOI=;
        b=YyM3d9F8NpTGqs+6Oz/bFIAwDIb6AMR9dQjZvcG7jugaKFVOss+SFYSKHn5pCRSCYr
         atqIMgKwQaeWpTsRFv4ZG8QNCX4WZuJuViyRchCJBxcIp5ccRTDkx5hpCWxB+no+ettb
         KgTLHgA7tq73Brk3UOcybhh2F+vU4epOsvBPlwyl5be3TDs1XrHC8J1Ot6ESqzM7ONv+
         /ZxelDbLEzGRibnzXWb4cDMn6rSHPXhvSIif/dA92YR0yWnsJ0ZANAG3qcMzVniUszzE
         rBTQlSurX9TXV5LG5nwdaZUud6L9MPFKhCLVTA4AbEMLQYYGEAuJ9eqFxJDXQDgwHxED
         7T/w==
X-Google-Smtp-Source: APXvYqzogf8+qz/m25zpvUSWX8ZermCY/xWYAkBSXOmj0SwgnGPv1iHRExXEqe+teTmO50fXGzbJuQ==
X-Received: by 2002:ad4:53c2:: with SMTP id k2mr37787769qvv.15.1559832784348;
        Thu, 06 Jun 2019 07:53:04 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id t30sm795128qkm.39.2019.06.06.07.53.03
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 06 Jun 2019 07:53:04 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hYtlH-0001FD-GL; Thu, 06 Jun 2019 11:53:03 -0300
Date: Thu, 6 Jun 2019 11:53:03 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: rcampbell@nvidia.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	John Hubbard <jhubbard@nvidia.com>, Ira Weiny <ira.weiny@intel.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Arnd Bergmann <arnd@arndb.de>, Balbir Singh <bsingharora@gmail.com>,
	Dan Carpenter <dan.carpenter@oracle.com>,
	Matthew Wilcox <willy@infradead.org>,
	Souptick Joarder <jrdr.linux@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/5] mm/hmm: HMM documentation updates and code fixes
Message-ID: <20190606145303.GA4698@ziepe.ca>
References: <20190506232942.12623-1-rcampbell@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190506232942.12623-1-rcampbell@nvidia.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 06, 2019 at 04:29:37PM -0700, rcampbell@nvidia.com wrote:
> From: Ralph Campbell <rcampbell@nvidia.com>
> 
> I hit a use after free bug in hmm_free() with KASAN and then couldn't
> stop myself from cleaning up a bunch of documentation and coding style
> changes. So the first two patches are clean ups, the last three are
> the fixes.
> 
> Ralph Campbell (5):
>   mm/hmm: Update HMM documentation
>   mm/hmm: Clean up some coding style and comments

I applied these two to hmm.git

>   mm/hmm: hmm_vma_fault() doesn't always call hmm_range_unregister()

This one needs revision

>   mm/hmm: Use mm_get_hmm() in hmm_range_register()
>   mm/hmm: Fix mm stale reference use in hmm_free()

I belive we all agreed that the approach in the RFC series I sent is
preferred, so these are superseded by that series.

Thanks,
Jason

