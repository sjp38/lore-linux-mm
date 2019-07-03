Return-Path: <SRS0=iaDK=VA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FAKE_REPLY_C,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A24BCC06513
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 18:03:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6E9E4218B8
	for <linux-mm@archiver.kernel.org>; Wed,  3 Jul 2019 18:03:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="GdaPl4pS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6E9E4218B8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EAF4D8E0012; Wed,  3 Jul 2019 14:03:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E601B8E0001; Wed,  3 Jul 2019 14:03:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D4F248E0012; Wed,  3 Jul 2019 14:03:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id B09128E0001
	for <linux-mm@kvack.org>; Wed,  3 Jul 2019 14:03:58 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id d26so3833538qte.19
        for <linux-mm@kvack.org>; Wed, 03 Jul 2019 11:03:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:mime-version:content-disposition:in-reply-to:user-agent;
        bh=lYX4hArZqbN+eTGDydHx247smNMZP20ckzpDZYDyj70=;
        b=p20XP4yAlp6R9oQYhEVjyYNF9+hz/R6L8uFUOyjvipilqdk5pEsNP2mAJ21KVigVt5
         k3Im/9EdDiVfWWIihihpGv1IQCkHn3oU7V1+eEl+4Bm9iq3pwr/+EEeVC5gfeBegzh6d
         2C2FMBgtdCC00VlqRoudhc+PH/38sLwOnCZF+kiplIrUVsUQEiEuprT7cGkA4QishbA9
         8fl1bFJod3dwiZqjiCt7en0172FY+UYbBODWTCj5aC8MsVhc85IK7EVeORH8wxTSL9gH
         RO2CnX7jkHKqLIUPMDsavse94uJnXvEm3+t/b4XzqK49zXCNoj/EVtKUZCM7A7sb5ac5
         G0Ig==
X-Gm-Message-State: APjAAAXLz+OtF3Bax8UuHQaaODtjtw5PCEfvzhH8XzXutkK2+0vAZJFB
	Qy80bVYULXJ/Y55p7xJXbujJ4gfLVOSOToqAcEUdBLGdItys2JYPr/893S8FPBnyTo3wCKQgnmj
	C0B0RBOG+TOPAbSwaY4bJC7P2dS4FAAXmywP7Ys9xe4eir8Jq5/dTvcELMX43Qzqbmw==
X-Received: by 2002:a0c:ad6f:: with SMTP id v44mr34415287qvc.40.1562177038499;
        Wed, 03 Jul 2019 11:03:58 -0700 (PDT)
X-Received: by 2002:a0c:ad6f:: with SMTP id v44mr34415258qvc.40.1562177038109;
        Wed, 03 Jul 2019 11:03:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562177038; cv=none;
        d=google.com; s=arc-20160816;
        b=P3oR9sD9ky37AbV6vzip4ZUPV6iVUjEGyxsYpXPuIVY8NXlDzX+a/OmO+uRo5kvnRm
         PeaM3SRZObdTGzB1hR3QKDjLO6B7/pW53hmi476RUXxWnxfBMFoMpboAkcUcGJFG2vTs
         wn4HVH0c3fwsxwuRNf766bEB55S7wg+UUDR89Q4uAjvSM8+Rf2fW3QAjxruVJAj8K2UH
         B/GhJQRj2WXShgZRTm2nzTfbbnZvSEaS/Yg7dfer6SFGY4WGdDhrzLnjyrDIyFnX0QcG
         MDrJsJmmtdxngX3borgAX1qjk2ZezrKXLhGTtBLpfQdkggKOX6xgmm1ucHSiajeW++IJ
         FK4A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:message-id
         :subject:cc:to:from:date:dkim-signature;
        bh=lYX4hArZqbN+eTGDydHx247smNMZP20ckzpDZYDyj70=;
        b=l5bNlidUfJFus9cN0vtvvo4Ow0MVwSEbcb8njgpnDD/dOp2uR3ztB8sUoYvCIkg0UW
         kJK9QmHGcIY/RUh+BJ+H89LhiznOmDC91GMBZlDIXVoZrU+L3MU7DtJ9F+fcu2LbD6Pz
         ZS+aMtEg98oscmB59wM5R5J+y9b+Qb7zSO+u9DH2ot8kyz6GFaaKdmOyOgY90dfKQccG
         /W1LdL1CKaM80R0Lm87f0hNfR50Mj2ahmNM6MEIxKvJFskYGZo/zXlLJNalWRMKLvs/u
         BGtidTTBQa3i/EWZmTfk3bZwzVxOfukmfb5FuTh57d2zPVBTc2yJ3YhE1eeK/JuYOTbc
         1f0g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=GdaPl4pS;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o14sor1888858qkg.171.2019.07.03.11.03.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 03 Jul 2019 11:03:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@ziepe.ca header.s=google header.b=GdaPl4pS;
       spf=pass (google.com: domain of jgg@ziepe.ca designates 209.85.220.65 as permitted sender) smtp.mailfrom=jgg@ziepe.ca
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=lYX4hArZqbN+eTGDydHx247smNMZP20ckzpDZYDyj70=;
        b=GdaPl4pS25oGRqKqhYVZvbGMctmnAHGdnVDY5M9r5E2gXod6kvV8ztPBkFUZyGMM4s
         clYw/MlR3HpP4fUWkXGOqUyErs3qjITlzLbXXg12O9Tm+nYZZaTCWOpGAzeQajKuGTZU
         0wZmmTjqvm2YnyiIapY0xjU8UbEcBknZzuv1w7IATnd4Sq1IJThXnD3h4aGhqzdo2ww1
         6dYcSuMv9naAdmn53AoZUwIOgY2ixkhgWUgG5M3h3qNUG7OVco2Jf970+GkH9fxchzv1
         Bwym1bXm36Zd5IvXjxpJKkA7FdRhwbFO3vyAQP2p0NEj/n2Yq8GEnqIn5HF5aibZNjgw
         i3Ng==
X-Google-Smtp-Source: APXvYqwAIbwqmaDg6afMKDuszd1tCKqefer9BuJ/SUVOZEN2k8Xz9Vx5WhWvm0C4hIeiM5DGRjiLAw==
X-Received: by 2002:a37:a10b:: with SMTP id k11mr29660901qke.76.1562177037895;
        Wed, 03 Jul 2019 11:03:57 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id f132sm1237440qke.88.2019.07.03.11.03.57
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 03 Jul 2019 11:03:57 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hijbp-0006qR-01; Wed, 03 Jul 2019 15:03:57 -0300
Date: Wed, 3 Jul 2019 15:03:56 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Christoph Hellwig <hch@lst.de>, AlexDeucher <alexander.deucher@amd.com>
Cc: Dan Williams <dan.j.williams@intel.com>,
	=?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
	Ben Skeggs <bskeggs@redhat.com>, Ira Weiny <ira.weiny@intel.com>,
	linux-mm@kvack.org, nouveau@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org, linux-nvdimm@lists.01.org,
	linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 20/22] mm: move hmm_vma_fault to nouveau
Message-ID: <20190703180356.GB18673@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190701062020.19239-21-hch@lst.de>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 01, 2019 at 08:20:18AM +0200, Christoph Hellwig wrote:
> hmm_vma_fault is marked as a legacy API to get rid of, but quite suites
> the current nouvea flow.  Move it to the only user in preparation for
> fixing a locking bug involving caller and callee.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
>  drivers/gpu/drm/nouveau/nouveau_svm.c | 54 ++++++++++++++++++++++++++-
>  include/linux/hmm.h                   | 54 ---------------------------
>  2 files changed, 53 insertions(+), 55 deletions(-)

I was thinking about doing exactly this too, but amdgpu started using
this already obsolete API in their latest driver :(

So, we now need to get both drivers to move to the modern API.

Jason

