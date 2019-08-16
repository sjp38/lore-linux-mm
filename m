Return-Path: <SRS0=YXmN=WM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1CB7DC3A59E
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 15:14:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CED692133F
	for <linux-mm@archiver.kernel.org>; Fri, 16 Aug 2019 15:14:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="oy5sZFjQ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CED692133F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4C0156B0005; Fri, 16 Aug 2019 11:14:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4705B6B0006; Fri, 16 Aug 2019 11:14:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3867F6B0007; Fri, 16 Aug 2019 11:14:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0009.hostedemail.com [216.40.44.9])
	by kanga.kvack.org (Postfix) with ESMTP id 114956B0005
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 11:14:55 -0400 (EDT)
Received: from smtpin24.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id B68AD180AD807
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 15:14:54 +0000 (UTC)
X-FDA: 75828638508.24.lake56_47effd6b16062
X-HE-Tag: lake56_47effd6b16062
X-Filterd-Recvd-Size: 5004
Received: from mail-qk1-f196.google.com (mail-qk1-f196.google.com [209.85.222.196])
	by imf28.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 15:14:54 +0000 (UTC)
Received: by mail-qk1-f196.google.com with SMTP id g17so4966512qkk.8
        for <linux-mm@kvack.org>; Fri, 16 Aug 2019 08:14:54 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=fov2CgaO1O1CFkZX4IfqnTZnTK7C3zpSvYgzXGSY56g=;
        b=oy5sZFjQp1BCVaEwQsb3+KNPFbSHSZHWPBMzBnqM3YkM8M6TeLN/TchFjkEdsICSuJ
         1C+Aqtldy/Y4ldUDXhcLTuhfNncF7+Dyd3fNJ1bom3uP8hS9LridrmdEdsAQXWEZtKjz
         7XP3pkdVorvFX0x7VQ1DMygwaFOvfV+UwasgUORcn3BEim4b1kFT8oE06M97uDUrjOv5
         mMHA/Z8hsM7HRGW+maHrZQD/1QDaaYGCk/ab/4r4vI2lVu52wx2id8gV5icj3phd9BLt
         KUOXu736r5AT7W/9wY/TxeK4Ryn6yfFSyNCnwDYASLlBBEV0NjKDADW49yLgEKf3SWZn
         2lUw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=fov2CgaO1O1CFkZX4IfqnTZnTK7C3zpSvYgzXGSY56g=;
        b=BBsk0B0oofQYhi1RIk7oSWj5f5mbNBxYM6+kiGN1Jcr2Qnl7Yzotd3i/k8WkB65P5f
         ORQDhRArk62eKPs6REq589ssGp+79SuFhcpt4xcr8O2c5c4LteToScFKLZkgVxGyQuCx
         FMP2Xtu+pgUZP1/iH//6JYUJBEjlKDFs8cH5jQenDZX15hNAt0wduw3Pyw15TYyuGckU
         ilmZYaJWV04lp9dLT50OEna2PER+op9zNwaaZ8OoiZf/4jCme2AHM2kDOVo95/QW7ft9
         TpwaRSlTCF/DQPNIOHo0rgtuzqMVipWSbVSHJA0PBppiy2o3fhSet74YObd06zCDot8W
         HYlQ==
X-Gm-Message-State: APjAAAXDBfWWHNPJiuMIphP99Kc20zzYE6OuvtAjds1YjFXo7nbMo2Px
	W7QhHKVhqYYAU+abVFHr4MAroIUdZxM=
X-Google-Smtp-Source: APXvYqxJQYOJO15q7RlRP/vufAQqFSxN3g0+gtugu+v5p95C5icfuXRjyKSuaK0zmQH83GKJGhGMfA==
X-Received: by 2002:a05:620a:1590:: with SMTP id d16mr9385834qkk.18.1565968493491;
        Fri, 16 Aug 2019 08:14:53 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id o127sm3158342qkd.104.2019.08.16.08.14.53
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 16 Aug 2019 08:14:53 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hydwK-0003JY-LJ; Fri, 16 Aug 2019 12:14:52 -0300
Date: Fri, 16 Aug 2019 12:14:52 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: linux-mm@kvack.org
Cc: Andrea Arcangeli <aarcange@redhat.com>, Christoph Hellwig <hch@lst.de>,
	John Hubbard <jhubbard@nvidia.com>,
	=?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
	Ralph Campbell <rcampbell@nvidia.com>,
	"Kuehling, Felix" <Felix.Kuehling@amd.com>,
	Alex Deucher <alexander.deucher@amd.com>,
	Christian =?utf-8?B?S8O2bmln?= <christian.koenig@amd.com>,
	"David (ChunMing) Zhou" <David1.Zhou@amd.com>,
	Dimitri Sivanich <sivanich@sgi.com>,
	dri-devel@lists.freedesktop.org, amd-gfx@lists.freedesktop.org,
	linux-kernel@vger.kernel.org, linux-rdma@vger.kernel.org,
	iommu@lists.linux-foundation.org, intel-gfx@lists.freedesktop.org,
	Gavin Shan <shangw@linux.vnet.ibm.com>,
	Andrea Righi <andrea@betterlinux.com>
Subject: Re: [PATCH v3 hmm 00/11] Add mmu_notifier_get/put for managing mmu
 notifier registrations
Message-ID: <20190816151452.GA8562@ziepe.ca>
References: <20190806231548.25242-1-jgg@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190806231548.25242-1-jgg@ziepe.ca>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 06, 2019 at 08:15:37PM -0300, Jason Gunthorpe wrote:
> This series is already entangled with patches in the hmm & RDMA tree and
> will require some git topic branches for the RDMA ODP stuff. I intend for
> it to go through the hmm tree.

> Jason Gunthorpe (11):
>   mm/mmu_notifiers: hoist do_mmu_notifier_register down_write to the
>     caller
>   mm/mmu_notifiers: do not speculatively allocate a mmu_notifier_mm
>   mm/mmu_notifiers: add a get/put scheme for the registration
>   misc/sgi-gru: use mmu_notifier_get/put for struct gru_mm_struct
>   hmm: use mmu_notifier_get/put for 'struct hmm'
>   drm/radeon: use mmu_notifier_get/put for struct radeon_mn
>   drm/amdkfd: fix a use after free race with mmu_notifer unregister
>   drm/amdkfd: use mmu_notifier_put

Other than these patches:

>   RDMA/odp: use mmu_notifier_get/put for 'struct ib_ucontext_per_mm'
>   RDMA/odp: remove ib_ucontext from ib_umem
>   mm/mmu_notifiers: remove unregister_no_release

This series has been applied.

I will apply the ODP patches when the series they depend on is merged
to the RDMA tree

Any further acks/remarks I will annotate, thanks in advance

Thanks to all reviewers,
Jason

