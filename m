Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D145FC4321A
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 19:49:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8710B21734
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 19:49:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="KARLerpz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8710B21734
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 260076B0006; Tue, 11 Jun 2019 15:49:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 212536B0008; Tue, 11 Jun 2019 15:49:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1004F6B000A; Tue, 11 Jun 2019 15:49:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id E22EE6B0006
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 15:49:00 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id n5so11848406qkf.7
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 12:49:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=dheT/EMDb4T+RApc8v8N2FtLE3hQvNF1jI6K4SKLtO8=;
        b=FXK9JlbgxMGhrYvSNWi5ku1izBo/yEAIFMaLDaaVQRtSFiu9B/sXIG9CIAVPCRnViW
         94jegqB5ZNwQn891DnAxu2cGLrU7lhvrr3OxzlHx25np7jKf4whQRyp7W30bY9t0SEPR
         W7jo5EcaVnTDubsnI1xUJnqgiuEG+T649O+LuE7lZeeR18ESRr1vD1/V04Ftu5nTXsyR
         jHFFsuXA9v3gvNTVTTmToUba5Y0tFeYZ283awa/FUmu8kf5EyJHsy+XeBjnpxosf8zEe
         Zejwdzy2bgk9vE1+3kAlqJWAkQvljsPZQ5Bun+60Yu7pWvy/hA3shExOBJMn+gtV0Kuq
         ZSzA==
X-Gm-Message-State: APjAAAVRqJyyLj01Hrq65i9aN+OtFTzOowntkUIka4vSLYc8/zYKkAUB
	bwryjyEypPFFDY/j+TpLXoXh1rrnVu4xbXmH6rxlcXQmpHS4IY9WLw+4ZbawsooUjVaP7wK2cZ3
	wI+nf1RCC4i8Wr2BLCJx6LKzEckab+zGBAihtKpLj8C8P4u5poeYybVs3yNvzinzbAA==
X-Received: by 2002:ac8:3345:: with SMTP id u5mr67323809qta.219.1560282540653;
        Tue, 11 Jun 2019 12:49:00 -0700 (PDT)
X-Received: by 2002:ac8:3345:: with SMTP id u5mr67323785qta.219.1560282540172;
        Tue, 11 Jun 2019 12:49:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560282540; cv=none;
        d=google.com; s=arc-20160816;
        b=F7xw2HIfVSPRTbwfgRGC8Ch6MmSTWyaLIngeNMUPKX0+nN1ZLLnfATmaWAnYipJ44b
         2BhtVaTyKmtal3Mjo5i0wVOjR69iA9Fm2tm9KHa141g84z1DJajrK29YnxNAHPs/oX4u
         CyQ/gBSOhr1TZIQwyTPwlGi5WzCnOkIdDnJqOfV6iAUksOj7zcxsOhwwfttbEK3FMA7v
         jp3yr2459u2rnIRWrQVVBmuljg3h5OBAiGfv0oCeu2sjy80bfZdciWb9roR/t1sEPuwp
         nHa55g6ifJtSnhfzM6ihiwVTbFydHJbEcdH9TPglxeoce5G+mnsq0Bsyobsg4gihdxM9
         DnSA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=dheT/EMDb4T+RApc8v8N2FtLE3hQvNF1jI6K4SKLtO8=;
        b=EOwr/v9xr0oVrfXOB9KWt7vHJWKTHSDi+G0i4PSXNbdjdcocZHyopQTuqvRUA6H97d
         3Qzy77Uc99Y2fehBJr70/73bclQbsr9hTTiDDNQukcmb1vFUDwhqirc2gBkdm+vYlYuf
         rFNO6f4Qx4AzP26I45NPEuvMZvIBsbhZ7uuVdvSvS5gyrcWaVVEjF43FLoGEvyqe5jU8
         Vn+IRSoP5/xL3awxkPfYSfgiWW2cX7IpYesSDY2zqIZJ67clpSY3aGUaChVIUj0S1aiC
         o9a995Vu9THovemEQqabTgTUnKUSM3VY/ZRhrz5iPwNBCzWRNt9R6QIJyuDKkgzO0q/V
         fAHw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=KARLerpz;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 207sor7842632qki.104.2019.06.11.12.49.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 11 Jun 2019 12:49:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=KARLerpz;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=dheT/EMDb4T+RApc8v8N2FtLE3hQvNF1jI6K4SKLtO8=;
        b=KARLerpzOvvIj3IeSArTupBFJwtO+dDGhTWToR4GRIOdhp5jyNWQH6gKAGwNJyiQ4U
         xCkP33zNk7FBLZe+Voo8dCCfx7wIB4dz2w5in+9dfr+0SUDLq0d7orxxPsoyNk3DtpJ4
         L9S3duKjQxW0McdT7XRm9Omr0K64Cpj09xwwLEanRjVh6IWFPsosaX+imndD2tPbPeQB
         FjnnbXv4dHkcKwvFZ+PCT06b9Jyb25/mybmzSoosPbMLQFcH82UhcYYjvkwHCRFFKaie
         nVhD3xpMNRX40iAA/yFNxeGBPVUFRysXuFmpx3gzh30qnakSYukbUtU4rsjR07o6ntSb
         +aSg==
X-Google-Smtp-Source: APXvYqzWz4wQqQxqhco5IULXJcXk646whmpSr99hd3VvEKfBiD/jhjxF/rS3VyznrgwL7ykbqH0Z2w==
X-Received: by 2002:a37:de18:: with SMTP id h24mr7448842qkj.147.1560282539428;
        Tue, 11 Jun 2019 12:48:59 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id g185sm3415686qkf.54.2019.06.11.12.48.59
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 11 Jun 2019 12:48:59 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hamlO-0007GH-Lg; Tue, 11 Jun 2019 16:48:58 -0300
Date: Tue, 11 Jun 2019 16:48:58 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Felix.Kuehling@amd.com,
	"Deucher, Alexander" <Alexander.Deucher@amd.com>
Cc: linux-rdma@vger.kernel.org, linux-mm@kvack.org,
	dri-devel@lists.freedesktop.org, amd-gfx@lists.freedesktop.org
Subject: Re: [PATCH v2 hmm 00/11] Various revisions from a locking/code review
Message-ID: <20190611194858.GA27792@ziepe.ca>
References: <20190606184438.31646-1-jgg@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190606184438.31646-1-jgg@ziepe.ca>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jun 06, 2019 at 03:44:27PM -0300, Jason Gunthorpe wrote:
> From: Jason Gunthorpe <jgg@mellanox.com>
> 
> For hmm.git:
> 
> This patch series arised out of discussions with Jerome when looking at the
> ODP changes, particularly informed by use after free races we have already
> found and fixed in the ODP code (thanks to syzkaller) working with mmu
> notifiers, and the discussion with Ralph on how to resolve the lifetime model.
> 
> Overall this brings in a simplified locking scheme and easy to explain
> lifetime model:
> 
>  If a hmm_range is valid, then the hmm is valid, if a hmm is valid then the mm
>  is allocated memory.
> 
>  If the mm needs to still be alive (ie to lock the mmap_sem, find a vma, etc)
>  then the mmget must be obtained via mmget_not_zero().
> 
> Locking of mm->hmm is shifted to use the mmap_sem consistently for all
> read/write and unlocked accesses are removed.
> 
> The use unlocked reads on 'hmm->dead' are also eliminated in favour of using
> standard mmget() locking to prevent the mm from being released. Many of the
> debugging checks of !range->hmm and !hmm->mm are dropped in favour of poison -
> which is much clearer as to the lifetime intent.
> 
> The trailing patches are just some random cleanups I noticed when reviewing
> this code.
> 
> This v2 incorporates alot of the good off list changes & feedback Jerome had,
> and all the on-list comments too. However, now that we have the shared git I
> have kept the one line change to nouveau_svm.c rather than the compat
> funtions.
> 
> I believe we can resolve this merge in the DRM tree now and keep the core
> mm/hmm.c clean. DRM maintainers, please correct me if I'm wrong.
> 
> It is on top of hmm.git, and I have a git tree of this series to ease testing
> here:
> 
> https://github.com/jgunthorpe/linux/tree/hmm
> 
> There are still some open locking issues, as I think this remains unaddressed:
> 
> https://lore.kernel.org/linux-mm/20190527195829.GB18019@mellanox.com/
> 
> I'm looking for some more acks, reviews and tests so this can move ahead to
> hmm.git.

AMD Folks, this is looking pretty good now, can you please give at
least a Tested-by for the new driver code using this that I see in
linux-next?

Thanks,
Jason

