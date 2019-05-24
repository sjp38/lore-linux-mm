Return-Path: <SRS0=0yrr=TY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7B677C072B5
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 14:36:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3093B2081C
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 14:36:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="E/xAAe6Y"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3093B2081C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B7AD86B000A; Fri, 24 May 2019 10:36:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B05076B000C; Fri, 24 May 2019 10:36:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9CB9F6B000D; Fri, 24 May 2019 10:36:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ua1-f70.google.com (mail-ua1-f70.google.com [209.85.222.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7374E6B000A
	for <linux-mm@kvack.org>; Fri, 24 May 2019 10:36:52 -0400 (EDT)
Received: by mail-ua1-f70.google.com with SMTP id k28so2220732uag.6
        for <linux-mm@kvack.org>; Fri, 24 May 2019 07:36:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:subject:message-id
         :references:mime-version:content-disposition:in-reply-to:user-agent;
        bh=GHLEPoYZVhV31cok7KrMb+3z0XgL2p9iJ8cXKGhCP18=;
        b=hoiqg4JViAmfsppculUpBQaDlax53Fieu8Cu6JCDVqgBKcvCeXd0TB31tp5pUxxTEn
         GTksafXQayJxy67kjcTgtJAjbNBO2ghM2OuJgR9ygfDyh3GYrO7KqjUtXdpNb411RtG5
         GlpNbjvggWjnHqkWqA9zoxMkbR7LirLKSs8pWyQieApAH50y92sFsbTQkJMcdViOY8lA
         T6yX752A3Ze82dNEkcAjwgpWIylx/g7xKRnJPDztTQsePTq3bOU+UIM4/K3idbPj+xr8
         swSLZaS3Pesf0hrnBVQnMQJtPIav2Y8nXOu0QwlABCd9TjTtgDqkBcRy1xrhw0o8OPEO
         H+7Q==
X-Gm-Message-State: APjAAAXVAKcrmTiqtjRk/NHJJjocghyyWh+NrjmUvgz3dBcwk98YbE7S
	LBPOfDkSUELLAREsaTRdbjhXiTKhYttC12QCRuK2oUAk8ccC0RLRHc8bQiGTwdCpuizkG6QnrWr
	NLKlHekEgaOOMpaMXICYHSFIt8KOsgAG22YeqJH9z1t9jEY1Q9xhDk2UTY+AAWfbSyQ==
X-Received: by 2002:ab0:e06:: with SMTP id g6mr29954317uak.82.1558708612033;
        Fri, 24 May 2019 07:36:52 -0700 (PDT)
X-Received: by 2002:ab0:e06:: with SMTP id g6mr29954250uak.82.1558708611469;
        Fri, 24 May 2019 07:36:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558708611; cv=none;
        d=google.com; s=arc-20160816;
        b=ma6gZlaV7HsOvykvggNICAcEX4gCfZwdjA0gqFIDRi53WOrnfAVo3E7EnMwkpR7rSm
         YiA2a4c09uF+2Txsg7aOegA8uaZBzftqa9J/lBrBI2rmYY2/4V9fSeuFy+nZjqxGoWHX
         vfenZ5Dj25TqHPPo/2aTPcbF9/mGz4U9Cac2BS2afhx9Y6Xo1VTSyQJ8MMSEmpewRm8L
         QFWerLWWryCFjvNZHflUgqgFCBycWJBNJzKBE0MWpiDiuC5og+4fnPtsLSQ3gm0BHMAw
         +8IF4yYM3CLb4+rVGQUPnZXa+StaUy+IrRZ3jH1qpjmH+yUUM0XGoY9CCGJF2m3P1jGy
         R5uQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:to:from:date:dkim-signature;
        bh=GHLEPoYZVhV31cok7KrMb+3z0XgL2p9iJ8cXKGhCP18=;
        b=AJnG/wkNgFg5s13/Ga02G+m9ZnLDcRaxH0DpYYwWVPjb5xMXlKi9h5kdFbdH2S8Na0
         /2yC69bZlw8hmS8sdBIYxW4GLDZOZnMjtg3VseoWzg/3ljTZIMwzApyELLFHB3lUBHsc
         KO5lunR5bbLXslEnwJKyjBHYSQEGN6tDsMS4CqeZ6nTwYXRfWSbTGRfmpkFlJ0Cg7J1X
         GT5JWcDnJPBIc7MCnBGXVlbsmyGVRH1GLnJGTxSlQ3FbZJIXveT17OKZ0m5AQFoF2jXB
         V0SVHf70+TGliYcTo2Tm5x9OmjOqQoW3bxWOg+zzlAQW/L/erf78jc8OsWASrymKJtZX
         EERw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b="E/xAAe6Y";
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y16sor1345930uar.63.2019.05.24.07.36.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 24 May 2019 07:36:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b="E/xAAe6Y";
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=GHLEPoYZVhV31cok7KrMb+3z0XgL2p9iJ8cXKGhCP18=;
        b=E/xAAe6YXU9QOMecdpW0NLj4tYVOmUE5cXCSK2GCu8YQ2DQJxh9KpUb9RSJk2uSgHh
         /KL9+bm9kuEEpQLzTzDb86QjLORjOFUCIDZQkZhDO53Sr/pPe2iOWjT/UriVqMv6J0X+
         xoxyXbE4laWCEbFThtbH3bgr435xvqqZCnWJsn9P9lZ9EIypiSnhTOOhQPwM3nZdZOLF
         gV0RUbSemnSX+NLHXTU8193PXMmOWpwPxFI69ut38XuoTTdACIeMyE8MGfs/n0B6jTDp
         Q6hECGn4f1yu/hdO/Mnzz6lLcbF6uBsNCA2/GGUmYwrcdNyWCqeRKOfOoNupCjorJEwA
         KJwg==
X-Google-Smtp-Source: APXvYqwALepCgA/Gj9CzqFz7y5GIFjL1yFDhI7VMA1q74UV17dLK6TZiq5cYc+zFoe9mNLWCiM208Q==
X-Received: by 2002:a9f:3083:: with SMTP id j3mr8771789uab.110.1558708610924;
        Fri, 24 May 2019 07:36:50 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-49-251.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.49.251])
        by smtp.gmail.com with ESMTPSA id e19sm1569046vsc.24.2019.05.24.07.36.50
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 24 May 2019 07:36:50 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hUBJR-0003nG-Pq; Fri, 24 May 2019 11:36:49 -0300
Date: Fri, 24 May 2019 11:36:49 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: linux-rdma@vger.kernel.org, linux-mm@kvack.org,
	Jerome Glisse <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>
Subject: Re: [RFC PATCH 00/11] mm/hmm: Various revisions from a locking/code
 review
Message-ID: <20190524143649.GA14258@ziepe.ca>
References: <20190523153436.19102-1-jgg@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190523153436.19102-1-jgg@ziepe.ca>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 23, 2019 at 12:34:25PM -0300, Jason Gunthorpe wrote:
> From: Jason Gunthorpe <jgg@mellanox.com>
> 
> This patch series arised out of discussions with Jerome when looking at the
> ODP changes, particularly informed by use after free races we have already
> found and fixed in the ODP code (thanks to syzkaller) working with mmu
> notifiers, and the discussion with Ralph on how to resolve the lifetime model.

So the last big difference with ODP's flow is how 'range->valid'
works.

In ODP this was done using the rwsem umem->umem_rwsem which is
obtained for read in invalidate_start and released in invalidate_end.

Then any other threads that wish to only work on a umem which is not
undergoing invalidation will obtain the write side of the lock, and
within that lock's critical section the virtual address range is known
to not be invalidating.

I cannot understand how hmm gets to the same approach. It has
range->valid, but it is not locked by anything that I can see, so when
we test it in places like hmm_range_fault it seems useless..

Jerome, how does this work?

I have a feeling we should copy the approach from ODP and use an
actual lock here.

Jason

