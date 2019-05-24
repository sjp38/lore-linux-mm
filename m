Return-Path: <SRS0=0yrr=TY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5B632C072B5
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 16:53:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0ED8E217F9
	for <linux-mm@archiver.kernel.org>; Fri, 24 May 2019 16:53:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="V2c3cbyo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0ED8E217F9
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9B59B6B0010; Fri, 24 May 2019 12:53:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9650B6B0266; Fri, 24 May 2019 12:53:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 854ED6B0269; Fri, 24 May 2019 12:53:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f198.google.com (mail-vk1-f198.google.com [209.85.221.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6046A6B0010
	for <linux-mm@kvack.org>; Fri, 24 May 2019 12:53:04 -0400 (EDT)
Received: by mail-vk1-f198.google.com with SMTP id z6so3909555vkd.12
        for <linux-mm@kvack.org>; Fri, 24 May 2019 09:53:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:subject:message-id
         :references:mime-version:content-disposition:in-reply-to:user-agent;
        bh=BWxqjKZCed63tdrqv52w7wsfWcnck29Bguoecq4JyuE=;
        b=VRnppWxHYQGLies1AH0v/r2Ld4O5qEUrCkDpBbQHlv3823kxGyJqXrXon4ejdWvvyd
         HK2L9a06Z5A+VKRKxy6DckuXwOGA/20hndLYB+9Bah27Wa62hFISiWcsLHqYlJCrU0TI
         rU6b2WPidmhdwDbj5BGPX7NrMqrs9BVix0yOEy0PnmxnU1LrmrtJ18p//890a4mOWeJU
         g8JmBVh7S+tGgdoEfskEDY710xP2Dvui9UKKanAAQcF2FCEb/jeEGGXVkG7VBGkOPenM
         BzOsR2tHNxsR82aCF0P4MTFQ1mstVLFQMamU+F3SG7virKoc63QGyE0acbfbr6MPgDmm
         j7RA==
X-Gm-Message-State: APjAAAXHjoh4lVOHtko/0wLEpX6en97jgs96iaSwl4jH8A1UjZD8t287
	gbgJMuxCBqhm8yEf5UP3dQ9ebyleI9hDJgPN3sDbPZ2M099jBzI9agCF0XqSsWr4AlJUP4qjUg4
	gRn72MoQoWn0EYxGcSdpwsCK+w/4ttEv1ZcCtZiCuulxjvE3lxjJ5boMoOTTVAg4Plw==
X-Received: by 2002:a1f:551:: with SMTP id 78mr6137377vkf.45.1558716784089;
        Fri, 24 May 2019 09:53:04 -0700 (PDT)
X-Received: by 2002:a1f:551:: with SMTP id 78mr6137306vkf.45.1558716783398;
        Fri, 24 May 2019 09:53:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558716783; cv=none;
        d=google.com; s=arc-20160816;
        b=Cw5Csl9lqOhGsALmEqXlugBy8PReGnndy664ANEnIQlEJzaNcWtxf52Wolzg4vA0xi
         iNAN44wnBOOXEEvvOkQdnIh10ciH10V9qnXuPrrJT6L6VMq1xyna9HG9hOtQaq7ZboPx
         gxtJ9gE1421BuaR2vDQ262tNDHXIH90d1YOg9QxS7jr2zFeENUp5xArl24QrFvXNIL5M
         Nqoigp69eME9DEFvjXL6u8Q/tmte03fp5urzeV/eiYs58j24Zthr+29VJAe55K1rHhfW
         hD+ko2RdgMstP1Hw2qjE7KEFeoyGpQt7y1n9zILm5GW0yqYY+tueJnX6v1uMO5fXZLiI
         q4mA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:to:from:date:dkim-signature;
        bh=BWxqjKZCed63tdrqv52w7wsfWcnck29Bguoecq4JyuE=;
        b=YuJrv9eedQyz8bvrnRZBq0ySUw2PTAzE1NU6P4C8Zyjt1Jd4Ph4tLq9wqtbObuyajQ
         SwLj6oQb9b8e9rB5b4p8CNrHOH1E004uqjH8e6NjdAkERHrwP4au7Fk4C6sND0Ez4NF+
         xk/KgeA35leu/OFLLeBoxajEN+OxUxlF6LIarDQU+PnJjWQgu21DByD2hVm1rp3a2G34
         XN/kxLjOtL/242HLlu/uvra1twJUc61f9ZF/54iI69rDxygIbApArngmkfpDVjeBsXSw
         L/JtgKqGmH2kZ0r6Ikocvkkd+7I/YMLARtwej35cAsJ82LyZB496bm5BfOKLiCOAXKsv
         OnUw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=V2c3cbyo;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i140sor777369vkd.23.2019.05.24.09.53.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 24 May 2019 09:53:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=V2c3cbyo;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=BWxqjKZCed63tdrqv52w7wsfWcnck29Bguoecq4JyuE=;
        b=V2c3cbyoJqcZX30pcTkJEv7QnnWfFOVUG/SZKLtnQEgMJVwm89vkCiLejgP7M+iRpN
         q/gLFJwalceC5ic9vkHhbkH+U/d7dt/5gsWtZqSmPEamXKr1uoECt4WeGoJqd2HwGhbx
         9Occ1equYYbcXlCB88viJlGsBFmUVprPlSaUrUnpgJaFB5VgTgvCVd56gO+SEN+aAAgm
         xm1VbLsF+wb2n+Ta5LcBu1FilJNm/nl1Mj5onw2ziQywv/g3tjrYI+IB0DZ9YrwYdgB0
         VEIEcUTbHmI4X7mxwSOIeASg6iishBSuXQpcZN/RP20qWAgLsgkprlD05w//8ySkAW73
         D/4A==
X-Google-Smtp-Source: APXvYqxGf4YX6m1bc63rX3ITovS0x9J+uBVKSme0zDKMj1gtik5rsITucqSrT8VXY0G62c80cqSI9A==
X-Received: by 2002:a1f:fe81:: with SMTP id l123mr6286152vki.51.1558716782783;
        Fri, 24 May 2019 09:53:02 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-49-251.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.49.251])
        by smtp.gmail.com with ESMTPSA id b2sm1470363vkf.16.2019.05.24.09.53.01
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 24 May 2019 09:53:01 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hUDRF-0008FA-F4; Fri, 24 May 2019 13:53:01 -0300
Date: Fri, 24 May 2019 13:53:01 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Christoph Hellwig <hch@infradead.org>, akpm@linux-foundation.org,
	Dave Airlie <airlied@redhat.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Jerome Glisse <jglisse@redhat.com>, linux-kernel@vger.kernel.org,
	linux-rdma@vger.kernel.org, Leon Romanovsky <leonro@mellanox.com>,
	Doug Ledford <dledford@redhat.com>,
	Artemy Kovalyov <artemyko@mellanox.com>,
	Moni Shoua <monis@mellanox.com>,
	Mike Marciniszyn <mike.marciniszyn@intel.com>,
	Kaike Wan <kaike.wan@intel.com>,
	Dennis Dalessandro <dennis.dalessandro@intel.com>,
	linux-mm@kvack.org, dri-devel <dri-devel@lists.freedesktop.org>
Subject: Re: RFC: Run a dedicated hmm.git for 5.3
Message-ID: <20190524165301.GD16845@ziepe.ca>
References: <20190523154149.GB12159@ziepe.ca>
 <20190523155207.GC5104@redhat.com>
 <20190523163429.GC12159@ziepe.ca>
 <20190523173302.GD5104@redhat.com>
 <20190523175546.GE12159@ziepe.ca>
 <20190523182458.GA3571@redhat.com>
 <20190523191038.GG12159@ziepe.ca>
 <20190524064051.GA28855@infradead.org>
 <20190524124455.GB16845@ziepe.ca>
 <20190524162709.GD21222@phenom.ffwll.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190524162709.GD21222@phenom.ffwll.local>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 24, 2019 at 06:27:09PM +0200, Daniel Vetter wrote:
> Sure topic branch sounds fine, we do that all the time with various
> subsystems all over. We have ready made scripts for topic branches and
> applying pulls from all over, so we can even soak test everything in our
> integration tree. In case there's conflicts or just to make sure
> everything works, before we bake the topic branch into permanent history
> (the main drm.git repo just can't be rebased, too much going on and too
> many people involvd).

We don't rebase rdma.git either for the same reasons and nor does
netdev

So the usual flow for a shared topic branch is also no-rebase -
testing/etc needs to be done before things get applied to it.

Cheers,
Jason

