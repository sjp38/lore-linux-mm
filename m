Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A2690C76186
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 17:18:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 57D842239F
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 17:18:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="TWoi52D8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 57D842239F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DC5A18E0002; Tue, 23 Jul 2019 13:18:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D76228E0008; Tue, 23 Jul 2019 13:18:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C965E8E0002; Tue, 23 Jul 2019 13:18:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ua1-f69.google.com (mail-ua1-f69.google.com [209.85.222.69])
	by kanga.kvack.org (Postfix) with ESMTP id A8A588E0002
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 13:18:19 -0400 (EDT)
Received: by mail-ua1-f69.google.com with SMTP id p13so4292575uad.11
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 10:18:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=0B8rPPy+2ZXzBZ5P/6QN4Hb9TBfPCAUoHiabvJr5FcE=;
        b=hRtuIKB9MScB5Jdun4cdPqkNz9N830F3ccE7V17ifWu4LwIKqjsaQJAFYhMMODpFqy
         V+qOPrNgRBWIwzPRX0oJgYsH9ueAIbKw70Iwhzt+7iV+ylDF83paO5ANSIDii+iZTcaj
         zgNp7/DywNdP8va7nP8CdiLcLwu97bDJM4Mqxzf3eylLSiK9p+zi9Z8vzaEP3BD7io0y
         D9u+UY1Xrj+v+jBZvAX9OOMiNXGWdeOPVZNTSXvTfnIcUWvLtgzBuOtZtaXwsviPs0XZ
         BVGNw+yz2L+/cIzhJP90R1KRypxb85vfrxqS1K2OCltrj0AplsBvTxKckHHYHKlWOt05
         2uSQ==
X-Gm-Message-State: APjAAAWNQ0Tp0CZsZWSQgSGMXzVOkF+BwC0raybBq0UpZ0vKe0Sy7X3r
	LpTbp1rw0GLawkUDo51X+skPhIV4r3C8MLDeVR/yk3icZTyoNhhFPBEGzMui7UYghcDezffoQjg
	GFjWEYzF2alO/HXXJ2iOkQk8AEvztcCfpuhVt6gTRSRFJSDjn/tp+/FMYM4EglS1T7w==
X-Received: by 2002:a67:1787:: with SMTP id 129mr46689335vsx.64.1563902299419;
        Tue, 23 Jul 2019 10:18:19 -0700 (PDT)
X-Received: by 2002:a67:1787:: with SMTP id 129mr46689276vsx.64.1563902298932;
        Tue, 23 Jul 2019 10:18:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563902298; cv=none;
        d=google.com; s=arc-20160816;
        b=k2wq0UExLK6hYE88OpP55XDtv/ktXZTFCeVmiBGmR5t5eXobQQ1549O/eMOvJDQKpa
         AKCSnOwG36s4mxac9XA34U/SrDLbYtFNZsLgrUP/j1gUU5RXg7UFnWUrymyZw62MaawF
         Ii5HFulvSL706Ck0L4Ont2HF9MD+ujs4uIX1PJ7iTZtqTp9u+czWp2CC0ndRbMd8+lRo
         w4rwPiWZw5jiwHP2SrgLPfIAZ3tCdSaKnpg5rivGOsyV0m2X3iFWAvU82p8sf/b6L4j1
         Gg58hmAtp5GrQ/C3K2pe3/zda1hs1QEwQKmmgkdyWOHAV3Lh+X0QzUBbbvM0iy46myn2
         l3Nw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=0B8rPPy+2ZXzBZ5P/6QN4Hb9TBfPCAUoHiabvJr5FcE=;
        b=uPUWyFj/nZ3bG12McBszMiPdvBW5QgbJuuTBKCxZh4ZKu8oQfmd6tY653F7cXZcdrs
         FcS7CFG37PlQXYFfT2C2f52iWcfDSWk4/yh20teJblq2NDPU4ZiZsmaSemCulFzlwNl7
         FE3BuJ6LTXRR7g2KW+PcNcdKx5y38nVj20CDGYJ01J4K6fBSF1IfjqPCsQG5aqUlSg1o
         a4aBVIeLBniVF9vOyI3UKP3wY9aUlo1jF0Fp1Nx95wT/ZmPTVusskcGs0YgRtA6aa+Sf
         wcHTLy71tJ8tCVdpZmhZ+FQZh8vnauBKeDxylBFgpPuGSktH/N5n1a5o6Je5R+quXnTD
         Butw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=TWoi52D8;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k23sor21837091vsj.22.2019.07.23.10.18.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Jul 2019 10:18:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=TWoi52D8;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=0B8rPPy+2ZXzBZ5P/6QN4Hb9TBfPCAUoHiabvJr5FcE=;
        b=TWoi52D8rfeqTBQSa1fcx6QWG63Ntk0exIFf5AUJVd3WTblBruQ+cylK1+Aq6U2g8I
         I7t4fdrtcdj5SN1bDc0/Kg0coJ86BhXzItFv8/tlfnAujkwPIO9ZZ2RjaZb7NUSbooI7
         3ltnRcDS0Wf4Dq2qNc6ARyJizVl0RXPIagQpi/49DQJufEQ7sgs3+URXsAHw1IKoV2Cz
         CStWHQDRV/RAeZ7idchpS6ZNJrNUZDt/3Eyjdita5OUUpQHlDwi9JI3k2/on6Wfa/hYW
         cRWNKC09OYoVLpdxT0M9vuFRG9rF1fqOAV+dU5wZlNcsyZrhEpXaXS46fiW0mqgmA7oc
         81tQ==
X-Google-Smtp-Source: APXvYqxuzXgliI3GFFRnGNkj/EgjQA5jk124NBKZFVu7wii1lUqI5vsy37of5hMl2W7MgMsFdFJF7A==
X-Received: by 2002:a67:1e44:: with SMTP id e65mr50704721vse.45.1563902298689;
        Tue, 23 Jul 2019 10:18:18 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id s67sm15723604vkb.30.2019.07.23.10.18.18
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 23 Jul 2019 10:18:18 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hpyQb-0002Yx-CQ; Tue, 23 Jul 2019 14:18:17 -0300
Date: Tue, 23 Jul 2019 14:18:17 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Christoph Hellwig <hch@lst.de>
Cc: Souptick Joarder <jrdr.linux@gmail.com>,
	=?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
	Ben Skeggs <bskeggs@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	Linux-MM <linux-mm@kvack.org>,
	"nouveau@lists.freedesktop.org" <nouveau@lists.freedesktop.org>,
	"dri-devel@lists.freedesktop.org" <dri-devel@lists.freedesktop.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Felix Kuehling <Felix.Kuehling@amd.com>
Subject: Re: [PATCH 1/6] mm: always return EBUSY for invalid ranges in
 hmm_range_{fault,snapshot}
Message-ID: <20190723171817.GE15357@ziepe.ca>
References: <20190722094426.18563-1-hch@lst.de>
 <20190722094426.18563-2-hch@lst.de>
 <CAFqt6zY8zWAmc-VTrZ1KxQPBCdbTxmZy_tq2-OkUi3TVrfp7Og@mail.gmail.com>
 <20190723145441.GI15331@mellanox.com>
 <20190723161907.GB1655@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190723161907.GB1655@lst.de>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 23, 2019 at 06:19:07PM +0200, Christoph Hellwig wrote:
> On Tue, Jul 23, 2019 at 02:54:45PM +0000, Jason Gunthorpe wrote:
> > I think without the commit message I wouldn't have been able to
> > understand that, so Christoph, could you also add the comment below
> > please?
> 
> I don't think this belongs into this patch.  I can add it as a separate
> patch under your name and with your signoff if you are ok with that.

Yep, thanks

Jason

