Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.3 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4634BC31E5E
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 18:19:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0166921721
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 18:19:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="EoBDSvdH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0166921721
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8DE0D6B0003; Wed, 19 Jun 2019 14:19:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 88F198E0002; Wed, 19 Jun 2019 14:19:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 77D928E0001; Wed, 19 Jun 2019 14:19:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5413E6B0003
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 14:19:26 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id g56so161762qte.4
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 11:19:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=j+sIitK0Ja8Ov8ieeJfPWbN0YkrvgCIASmHhWLMuHLw=;
        b=UaxnZNlMXwy33eXTegcb9k14nw6Xd+cVrUgyxHigGtrRUBL82Ww4SN4qSzJ99RRvin
         02Gs+YBeOr5G1lpIFpKnTmipAy06rBrxFi8qpiQogSGi9fJtdLpmy6Xry9vRnhwyw+8S
         UJ468IA3/CNZIvhtnuSL1qFLo/N9VWuYTNemx8NDBPoBwlkI4NF3XdnpStl9Ylx5MNMc
         3XbznIPjg5l5eWMRmEw9Ymxyb1EhSncu+37P3+oEyJBBYNkwoqdMdRja8Kq8tr9R4e6g
         CcJrjnXQAz/Aj2OxCJBihszgAun1YcnYw9EJq1T6UlmOCUCJY9IpoLKBuojKnox7zrdy
         pKJw==
X-Gm-Message-State: APjAAAWizMrNMUGS5LBvkfqh/eLkPWPPrdm82u69Zq49/6xHhwI3fzqp
	KDASwMQtIHEXri8vGlipbbBt4w8lNihzeekKR5VAgCp7PQhcSOOne27ByPMIJNASgRECyRrGAZs
	41ys1/AtQEfA9OKPf5U+o7Lq1o4mQqR/K4153tDIXcgeff0kJVs5SBKb6bgBMMD3DWg==
X-Received: by 2002:aed:3b25:: with SMTP id p34mr107006442qte.289.1560968366029;
        Wed, 19 Jun 2019 11:19:26 -0700 (PDT)
X-Received: by 2002:aed:3b25:: with SMTP id p34mr107006366qte.289.1560968365161;
        Wed, 19 Jun 2019 11:19:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560968365; cv=none;
        d=google.com; s=arc-20160816;
        b=fJgK7FfQ6bxo12r1grprUaU755cwR8o5xIlAEcgkNDLDsDlckdkzYMauFKRBU1hasb
         T+GQGaLWHlpe6KHMKbrXOtC98n7YWQ1I8EpuMIJz3gLDrnVhTTXDJBCx6o5Ho4eG/yCQ
         Hj8WOudmdxAYuEEaWhy73CWVowEN2+Nrl8oLMYl+LLTdIjor2GrNBR16sQl4f6BOf8Zl
         jWHsVuv4kdFv0XuoHIgN+xYq5Yc59DrDxzNmPvHEVxgrdWgfPqADj2+gY8CnmVhhLdpV
         VKwg3/Fe5QknCgvRYwPCb8XduNGCKRHF4CqLWrAK9DaAbHUaLqugNPAfI+h1EbAFfoaf
         +66A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=j+sIitK0Ja8Ov8ieeJfPWbN0YkrvgCIASmHhWLMuHLw=;
        b=lE/xkSaO6c5ovjlM8FzoaXf2TvbdOHGRiObD+/HLzev5nhNZMe0rtAlPju+LxMtZJt
         BP50PW281wkO2vB6+nqonNA4CavsBxYQEJSDszqbQwaRumwJNow/lvrGRzGEQQXcbKeY
         Yf5flOBMTOIKTzAqKvPqOR/NTRMBDX7rDAws4HWpBT+1H21962QPsti7aPpoZnRsmRB3
         kWdAx3PRQLQQG26RohyvBsKw5m44HLA+ntOWWjpGeyF1MKi8dnwVZStpEOazjAOaY0M2
         7FPntsXawZlBuV5ug/GMSjC++cl3OJIA7DE98Vt7PRmc8ehXES2diROZJQ7h06MmgdR3
         ubDQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=EoBDSvdH;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b34sor27498516qta.71.2019.06.19.11.19.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 19 Jun 2019 11:19:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=EoBDSvdH;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=j+sIitK0Ja8Ov8ieeJfPWbN0YkrvgCIASmHhWLMuHLw=;
        b=EoBDSvdHfhYd93z8CePBywWHH5bXHAGcXWzOuMLu3/Uzv0MQq7Oam+sAX1Fb7CAk0c
         TJxbr4Wv0/dsOhypCrBG1Gfvu19Gzh1Rl4YrdYTtyiZDVpGot3JGHQS4tKbhDA26+wlS
         NHg9l8u9uVqf2htEjwoSE6SLxVUtPcB5jBlkv236SpPAneNbIGgeXlwOnBB5O/O/foEB
         sQIAgR9sw9NI31785FF4XFeb1aYwjw7IbmedaRaHIZxAz3ePgaJLV84aScqYjsfBC/4L
         bnWCVKMh/fD+HbDYkyAoE78LoiM2L5ceAP3zZNYP8wXBSrgjxJLnv97UmhMOWJKLoWl3
         j/rQ==
X-Google-Smtp-Source: APXvYqwc1d95Ltcmqx/CriKy9P5GUR2ZkHf3pjzc5gWGdXWLliAR4hpwJBxDIhEgyrqz+pevhmgebw==
X-Received: by 2002:aed:3e7c:: with SMTP id m57mr102301688qtf.204.1560968364678;
        Wed, 19 Jun 2019 11:19:24 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id 15sm10668885qtf.2.2019.06.19.11.19.23
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 19 Jun 2019 11:19:23 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hdfB5-0002ic-8m; Wed, 19 Jun 2019 15:19:23 -0300
Date: Wed, 19 Jun 2019 15:19:23 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Christoph Hellwig <hch@lst.de>,
	=?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
	Ben Skeggs <bskeggs@redhat.com>, Linux MM <linux-mm@kvack.org>,
	nouveau@lists.freedesktop.org,
	Maling list - DRI developers <dri-devel@lists.freedesktop.org>,
	linux-nvdimm <linux-nvdimm@lists.01.org>, linux-pci@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Subject: Re: dev_pagemap related cleanups v2
Message-ID: <20190619181923.GJ9360@ziepe.ca>
References: <20190617122733.22432-1-hch@lst.de>
 <CAPcyv4hBUJB2RxkDqHkfEGCupDdXfQSrEJmAdhLFwnDOwt8Lig@mail.gmail.com>
 <20190619094032.GA8928@lst.de>
 <20190619163655.GG9360@ziepe.ca>
 <CAPcyv4hYtQdg0DTYjrJxCNXNjadBSWQ5QaMJYsA-QSribKuwrQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4hYtQdg0DTYjrJxCNXNjadBSWQ5QaMJYsA-QSribKuwrQ@mail.gmail.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 19, 2019 at 09:46:23AM -0700, Dan Williams wrote:
> On Wed, Jun 19, 2019 at 9:37 AM Jason Gunthorpe <jgg@ziepe.ca> wrote:
> >
> > On Wed, Jun 19, 2019 at 11:40:32AM +0200, Christoph Hellwig wrote:
> > > On Tue, Jun 18, 2019 at 12:47:10PM -0700, Dan Williams wrote:
> > > > > Git tree:
> > > > >
> > > > >     git://git.infradead.org/users/hch/misc.git hmm-devmem-cleanup.2
> > > > >
> > > > > Gitweb:
> > > > >
> > > > >     http://git.infradead.org/users/hch/misc.git/shortlog/refs/heads/hmm-devmem-cleanup.2
> > >
> > > >
> > > > Attached is my incremental fixups on top of this series, with those
> > > > integrated you can add:
> > >
> > > I've folded your incremental bits in and pushed out a new
> > > hmm-devmem-cleanup.3 to the repo above.  Let me know if I didn't mess
> > > up anything else.  I'll wait for a few more comments and Jason's
> > > planned rebase of the hmm branch before reposting.
> >
> > I said I wouldn't rebase the hmm.git (as it needs to go to DRM, AMD
> > and RDMA git trees)..
> >
> > Instead I will merge v5.2-rc5 to the tree before applying this series.
> >
> > I've understood this to be Linus's prefered workflow.
> >
> > So, please send the next iteration of this against either
> > plainv5.2-rc5 or v5.2-rc5 merged with hmm.git and I'll sort it out.
> 
> Just make sure that when you backmerge v5.2-rc5 you have a clear
> reason in the merge commit message about why you needed to do it.
> While needless rebasing is top of the pet peeve list, second place, as
> I found out, is mystery merges without explanations.

Yes, I always describe the merge commits. Linus also particular about
having *good reasons* for merges.

This is why I can't fix the hmm.git to have rc5 until I have patches
to apply..

Probbaly I will just put CH's series on rc5 and merge it with the
cover letter as the merge message. This avoid both rebasing and gives
purposeful merges.

Thanks,
Jason

