Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_MUTT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2C51AC169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 22:50:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D9A9B2184E
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 22:50:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="Xyicrd65"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D9A9B2184E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7514D8E0184; Mon, 11 Feb 2019 17:50:55 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 701158E017F; Mon, 11 Feb 2019 17:50:55 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5C9008E0184; Mon, 11 Feb 2019 17:50:55 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 19C5E8E017F
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 17:50:55 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id y8so449275pgq.12
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 14:50:55 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=g/wkTXu46FNOCtPsm2RcpgDTiMDCp2Wv41qyxuMJ8uw=;
        b=YlsBedrCHWOXO5++QX/QqmMybsJsFiWpmYJ8Gf75zgvSp6u1m7P6q5YU6YsTHg9P4p
         9Q6/2k4AI2vIaUfhvorOdFsxKfILz2CeDXjN6YLuW5rcNgMM17xVJz4+maAiVe26mrC5
         /gZzxTGhw9xopjvcYQorHU8b92kQ8GvIcAMf+VXr7Yls4AqE7YL/sh9ikUCHXkX6uLnl
         aC26FM1fdJOKcUv/y64yTGmUq5KMwaUTLYanFouGPrANmPWI0XagNTPKNn6pdP3SSX3p
         Ivst39hwLjPXa2yrG+Z9R0gXSoN96peLAcV9BsyfEF0RDD3A5mG4jVONCCrlTgsNZgNX
         VKng==
X-Gm-Message-State: AHQUAuZRApBlj61P1iFa78fAsmb6K9mhQ46K5oZjKLvzDR1LaqMy774J
	3yVTvkmDMUU6OrUp64HNRGm3eiFtrTDibGeKhhqS2mcpxRPGx17Mj5LEyifc+s1+uFT56KMdvq6
	BKlwXX/rLd3BxWO/XWtyVnSuZ8N7tMPTSDWUD+vH3qDjqDyiV2CV7SnnF9ZNXl9G/V4hBIlNuSm
	uJrxMGE+m1y7jiqHm+ZADEjxuy2CUKMl14AxhJ3A8Bo6o27SfyFPuGZQpU38FRSWYi3WHm/nGFy
	dWk8O9zV3btcTZKyUB0wji8LuOl/4avn/046EU9gN2afVvtF+MgJa4jiKER4s/15p093X1bLC19
	oDU0HQjACHQgl69arFdBxrtYpGGxnLTEZ3dVsCJBev41IA4JIigPwB9fZV1EpUI2i8uUPQq/b4k
	W
X-Received: by 2002:a63:f552:: with SMTP id e18mr580432pgk.239.1549925454774;
        Mon, 11 Feb 2019 14:50:54 -0800 (PST)
X-Received: by 2002:a63:f552:: with SMTP id e18mr580397pgk.239.1549925454077;
        Mon, 11 Feb 2019 14:50:54 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549925454; cv=none;
        d=google.com; s=arc-20160816;
        b=0Bj2c/LhNshh1cuP89HNZ3HBIsicosGP4ZM4IGA5hZGHQuyH5dA1MVKWvXPClYw83u
         EaIClhu2Z2DLDxl+Ud6ZZ5PLSl0XEffEiLH9MWSp4t6xMmaRov/pZvAdpGJVo9kbabhJ
         C/V0Amz4AEeqqYN1wNRINnt0Ig1A6RFgNqXNbfHoYJXJYYinTlGr6pfPXPTPuZW6ZLvx
         9PTYEb1jGofENP7hoDqeK6ckFSZCOZbhlkxIVzp1by5VKiFeoF6CuZZQ/i4d88tGLACs
         rAoiA1/g9vv5ki2KNAWRiICJMqI8SErT+4Et8ha2Gb0D4DyRXuPGbG1Cg9hB0sI8O/6O
         pkNQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=g/wkTXu46FNOCtPsm2RcpgDTiMDCp2Wv41qyxuMJ8uw=;
        b=tg2IIhxEBy3ztGib4gC4AsAlLGBkNDVK6ezV6eZ/6dKab4Ntw7wiSbj/bVbtfDcqhj
         C0NhpPE781LUiqbtVW3+Tgr9MYVUmq9EocnGX2rdonmoz8/UPT5n8VPUaoQrgdQLyPHU
         DF5y/b7iuC8sjzzD/tatX0h8oKm77SD9hLrUbC47tVr0h6cM6yuAeexyVp+A31ynNoBb
         9PR+Z1wsigOcoJ1NQL5f5afJ1ogJaDNqU0yG9+rmA/IDMs8vNOE87JnYJbieOpWYJ7ol
         7soZQ2wjQUeF3mWqJ49QN2SMyVcdcewNrayGxbm7s1ef4irEKLjqii51c9KUPZfikQLD
         YjWQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=Xyicrd65;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b5sor16990610pfj.35.2019.02.11.14.50.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Feb 2019 14:50:54 -0800 (PST)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=Xyicrd65;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=g/wkTXu46FNOCtPsm2RcpgDTiMDCp2Wv41qyxuMJ8uw=;
        b=Xyicrd65GrNQI2Ux5ANGkLgkEuWZD+V8zy3lXCzVtCwHfz+Pxa5RqFgZPBlj/bQR1x
         4o8n5wvByoZRcFE9M3AaAY3O16dGh1VDI3zvsic+R30HCkc4h1VvB4DicoF6eiJTc6tf
         oVEfSVLiFE4J63MZduYr+ZlerunKjxa7az7slCF6bcMu8qHtEe7WvQLcVGuyLNaZhHST
         U1NYwp8s4lnQmY+x83d71JHYQcZ0AqTTSHuZ66NQfUwNPWkKOj86y7snH64M7fz47UhO
         GvT88qxEaj02hIYWJwcccVe66PSGXxw4YqdBuaYVWdhsK8trnOv2m0nCOq9M9ywl0SPc
         V9ig==
X-Google-Smtp-Source: AHgI3IZ7DSKOYRlpvuhZ2qLbJkP0aOIpfJquIji12SQBslBl1jfLdEzQLIHmQEmomUVN47PwKzlyug==
X-Received: by 2002:aa7:8199:: with SMTP id g25mr698005pfi.46.1549925453650;
        Mon, 11 Feb 2019 14:50:53 -0800 (PST)
Received: from ziepe.ca (S010614cc2056d97f.ed.shawcable.net. [174.3.196.123])
        by smtp.gmail.com with ESMTPSA id a187sm10236492pfb.61.2019.02.11.14.50.52
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 11 Feb 2019 14:50:52 -0800 (PST)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1gtKPc-0003PQ-8i; Mon, 11 Feb 2019 15:50:52 -0700
Date: Mon, 11 Feb 2019 15:50:52 -0700
From: Jason Gunthorpe <jgg@ziepe.ca>
To: "Weiny, Ira" <ira.weiny@intel.com>
Cc: "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	Daniel Borkmann <daniel@iogearbox.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Marciniszyn, Mike" <mike.marciniszyn@intel.com>,
	"Dalessandro, Dennis" <dennis.dalessandro@intel.com>,
	Doug Ledford <dledford@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	"Williams, Dan J" <dan.j.williams@intel.com>
Subject: Re: [PATCH 0/3] Add gup fast + longterm and use it in HFI1
Message-ID: <20190211225052.GL24692@ziepe.ca>
References: <20190211201643.7599-1-ira.weiny@intel.com>
 <20190211203417.a2c2kbmjai43flyz@linux-r8p5>
 <20190211204710.GE24692@ziepe.ca>
 <20190211214257.GA7891@iweiny-DESK2.sc.intel.com>
 <20190211222208.GJ24692@ziepe.ca>
 <2807E5FD2F6FDA4886F6618EAC48510E79BCF37B@CRSMSX101.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2807E5FD2F6FDA4886F6618EAC48510E79BCF37B@CRSMSX101.amr.corp.intel.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 11, 2019 at 10:40:02PM +0000, Weiny, Ira wrote:

> > Many drivers do this, the 'doorbell' is a PCI -> CPU thing of some sort
> 
> My surprise is why does _userspace_ allocate this memory?

Well, userspace needs to read the memory, so either userpace allocates
it and the kernel GUP's it, or userspace mmap's a kernel page which
was DMA mapped.

The GUP version lets the doorbells have lower alignment than a PAGE,
and thes RDMA drivers hard requires GUP->DMA to function..

So why not use a umem here? It already has to work.

> > > This does not seem to be allocating memory regions.  Jason, do you
> > > want a patch to just convert these calls and consider it legacy code?
> > 
> > It needs to use umem like all the other drivers on this path.
> > Otherwise it doesn't get the page pinning logic right
>
> Not sure what you mean regarding the pinning logic?

The RLIMIT_MEMLOCK stuff and so on.

> > There is also something else rotten with these longterm callsites,
> > they seem to have very different ideas how to handle
> > RLIMIT_MEMLOCK.
> > 
> > ie vfio doesn't even touch pinned_vm.. and rdma is applying
> > RLIMIT_MEMLOCK to mm->pinned_vm, while vfio is using locked_vm.. No
> > idea which is right, but they should be the same, and this pattern should
> > probably be in core code someplace.
> 
> Neither do I.  But AFAIK pinned_vm is a subset of locked_vm.

I thought so..

> So should we be accounting both of the counters?

Someone should check :)

Since we don't increment locked_vm when we increment pinned_vm and
vfio only checke RLIMIT_MEMLOCK against locked_vm one can certainly
exceed the limit by mixing and matching RDMA and VFIO pins in the same
process. Sure seems like there is a bug somewhere here.

Jason

