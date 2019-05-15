Return-Path: <SRS0=idO3=TP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2410BC04E84
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 16:36:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BF6C42082E
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 16:36:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="Vl4rPNMI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BF6C42082E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 17E656B0007; Wed, 15 May 2019 12:36:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 12F6E6B0008; Wed, 15 May 2019 12:36:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 01E2D6B000A; Wed, 15 May 2019 12:36:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id C21796B0007
	for <linux-mm@kvack.org>; Wed, 15 May 2019 12:36:31 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id e69so262173pgc.7
        for <linux-mm@kvack.org>; Wed, 15 May 2019 09:36:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=fCWOmMbYwBQjYpMUOZu+jCfA4EruupzyVhAEZXgIrgA=;
        b=RCZ/NLCzbx4xjY4rhpyd0bgwfVlbi8/tH2kpPhpiFoc/Cy5V+WzVBMqELFdVff0S/E
         DlWOfAr1QfpbEXk7eIsltRxm6r4JU5Kv3wdn2wldRdOJuHtZqwXvowEe0CkQihEMwo8j
         iKY/7oCNC3nI1jUPIxrTV7/8IdkqifeEWydjWbTwaCidGlI+hJhtmRv4bG7t4MfAIDzK
         iK0HpwA5nkiYfBIwL3KEamIcd4ncDnV1LOB65oCsqCLIyRqQC7lBeGwjNTYG1ZUIp12B
         1vToLrR2xi0kVfuC4WYnds2TyVyJzzAj4VaLDk4DBUw/z2Qi3wH6t4XCvKrUQBairIbN
         oUsQ==
X-Gm-Message-State: APjAAAXdkPVt0Pqt5xvx6tWZItQKuDgZEBCeFTKDH0ioL0IGRqj3mp7N
	G4tvkFtH6r67tCa1zpYnFb2b7lUK7FNFoAQbhG8+q/NUIi2f6SoOz2zx/S29xla6Kiil3VTC+IT
	preaDpCo9QtzLgK+V+mVMBzVGkMfHS6mybf7z/ofl7B09t1cZpv4ETPE9Xke2+e+Y+w==
X-Received: by 2002:a63:4c15:: with SMTP id z21mr1669125pga.395.1557938191230;
        Wed, 15 May 2019 09:36:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxrELojJ8kY7eUaub6pUygPMKJIaOiyWS03JXuaReKwqYu+4e5EyaGLKz607pdRTu2DVm9g
X-Received: by 2002:a63:4c15:: with SMTP id z21mr1669055pga.395.1557938190344;
        Wed, 15 May 2019 09:36:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557938190; cv=none;
        d=google.com; s=arc-20160816;
        b=XOTXmThK8+90f3yaCR5g7IhPX+86wpF7/BTjoMrMwi6zDa741rKsP1LpHveVEIIYON
         tt3LyuPbzaFu/gl4boHWGCdngvqH2t0q/CdIOSzgGiwwS1yp/MtoXpWEQw1dqcj66taX
         qqbt5Yc/pRageGBb0H0qPtXzM/eKSfpG14WuWzQUkokR6yC8ZGvzjE9YXwVPBDVQ0FJL
         N2nWARwkc5UFXVbsTbLkYE6on+/Wt8ohVeOHodTa5QLE2wTKcFuYCd82dCQZ1M+J3AhZ
         prlMb30SlGouT4MPDRwgWimW878kArssahMHLtX6AaeplzsxiGzcqVGC683KpNeYCBNQ
         9X+Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=fCWOmMbYwBQjYpMUOZu+jCfA4EruupzyVhAEZXgIrgA=;
        b=uFPWhb+i+FKW/v+k+trf/LL7ZCYx7xpva0w4ZfcL2BBB0LAd/eEuIJdOmurPoAAcQQ
         g4rdHpDusNMx9u5va1iLwgIZLvlnvw6fSWpPZVZQCdXaBNJTPlCrmCaRQ+7Rz4C7ZzXg
         BjzLQtywMFY1S1hH2B6Tv2j3B2OrgAVP/xiUetOQOsxRLcBOnuM+EWEA5F511Z/vuSt9
         hCHDMQHLvN/mL4tigUY6y4ylNyWCL+zWqm+o6bifoFaUN5Gy9dvac1t8PgpN+JzmhsNU
         w6kUkLoJgDQmKe8Ds6ZkkrA2VKkWci5/Kz2fIO5l34THfuSK27G1D7BJPoRdseNGW1B4
         +aJQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=Vl4rPNMI;
       spf=pass (google.com: domain of leon@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=leon@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id b12si2297159pgl.77.2019.05.15.09.36.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 May 2019 09:36:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of leon@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=Vl4rPNMI;
       spf=pass (google.com: domain of leon@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=leon@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from localhost (unknown [37.142.3.125])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 54BB72082E;
	Wed, 15 May 2019 16:36:29 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1557938190;
	bh=fCWOmMbYwBQjYpMUOZu+jCfA4EruupzyVhAEZXgIrgA=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=Vl4rPNMIsxH2DcxFK2owU3okuYZCpInKI99vk4sctLlCNg7BZhhHibDPCniiSF8RS
	 ixCupc9hSrdnfljl/6k+yWflkSx3qFAFZHpzJhfqBdzBncW5+Kj9HVTHC1EH6vtKcV
	 a0cGXjLOZAAKMxhb+r/GLYVh4DRkm1Efd7O513bQ=
Date: Wed, 15 May 2019 19:36:26 +0300
From: Leon Romanovsky <leon@kernel.org>
To: Yuval Shaia <yuval.shaia@oracle.com>
Cc: RDMA mailing list <linux-rdma@vger.kernel.org>,
	linux-netdev <netdev@vger.kernel.org>,
	linux-mm <linux-mm@kvack.org>, Jason Gunthorpe <jgg@ziepe.ca>,
	Doug Ledford <dledford@redhat.com>
Subject: Re: CFP: 4th RDMA Mini-Summit at LPC 2019
Message-ID: <20190515163626.GO5225@mtr-leonro.mtl.com>
References: <20190514122321.GH6425@mtr-leonro.mtl.com>
 <20190515153050.GB2356@lap1>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190515153050.GB2356@lap1>
User-Agent: Mutt/1.11.4 (2019-03-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 15, 2019 at 06:30:51PM +0300, Yuval Shaia wrote:
> On Tue, May 14, 2019 at 03:23:21PM +0300, Leon Romanovsky wrote:
> > This is a call for proposals for the 4th RDMA mini-summit at the Linux
> > Plumbers Conference in Lisbon, Portugal, which will be happening on
> > September 9-11h, 2019.
> >
> > We are looking for topics with focus on active audience discussions
> > and problem solving. The preferable topic is up to 30 minutes with
> > 3-5 slides maximum.
>
> Abstract: Expand the virtio portfolio with RDMA
>
> Description:
> Data center backends use more and more RDMA or RoCE devices and more and
> more software runs in virtualized environment.
> There is a need for a standard to enable RDMA/RoCE on Virtual Machines.
> Virtio is the optimal solution since is the de-facto para-virtualizaton
> technology and also because the Virtio specification allows Hardware
> Vendors to support Virtio protocol natively in order to achieve bare metal
> performance.
> This talk addresses challenges in defining the RDMA/RoCE Virtio
> Specification and a look forward on possible implementation techniques.

Yuval,

Who is going to implement it?

Thanks

>
> >
> > This year, the LPC will include netdev track too and it is
> > collocated with Kernel Summit, such timing makes an excellent
> > opportunity to drive cross-tree solutions.
> >
> > BTW, RDMA is not accepted yet as a track in LPC, but let's think
> > positive and start collect topics.
> >
> > Thanks

