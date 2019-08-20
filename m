Return-Path: <SRS0=/Q+j=WQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9BDB2C3A589
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 13:31:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5459122CF7
	for <linux-mm@archiver.kernel.org>; Tue, 20 Aug 2019 13:31:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="kyQ9OWt0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5459122CF7
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 038F16B026E; Tue, 20 Aug 2019 09:31:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F2B816B026F; Tue, 20 Aug 2019 09:31:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E19C66B0270; Tue, 20 Aug 2019 09:31:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0167.hostedemail.com [216.40.44.167])
	by kanga.kvack.org (Postfix) with ESMTP id BEF566B026E
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 09:31:08 -0400 (EDT)
Received: from smtpin05.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 705EA8248AB3
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 13:31:08 +0000 (UTC)
X-FDA: 75842892216.05.land90_7e4d25982ca4d
X-HE-Tag: land90_7e4d25982ca4d
X-Filterd-Recvd-Size: 6320
Received: from mail-qt1-f195.google.com (mail-qt1-f195.google.com [209.85.160.195])
	by imf21.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 20 Aug 2019 13:31:07 +0000 (UTC)
Received: by mail-qt1-f195.google.com with SMTP id y26so5982690qto.4
        for <linux-mm@kvack.org>; Tue, 20 Aug 2019 06:31:07 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=aYpPZYtqod+fTEVMSorWhJ9m+fKXe1m4+frfAcmvGyw=;
        b=kyQ9OWt0i7+BfpuIcyUPTFQLZeuohCEC5hlVUNQiEKpacPgte/tVYaXCcoWS0iNX46
         LbDElheqaJ2KHddRS3Bu1aFYUKIF2VpbD9EaDtyp4ulfo2y9LapY2j2xgHMY5n6AgQGw
         h4SFdWkbBCEN0DxcCvSoBBbBbofopvxvLfyOOYwAaZFocYVAJnpeBoqzpNLDQWNPUm6p
         i5owmJsN0JKV6XnsgkHqBSTsTXrlH7ufNqL47j8nTzIRKN8roxX/xH2mNEAvLkFk1b2T
         eLX65YwAZeD6TPycNJswzneMyzYbv45HIRhTCNU/IO+ns1pewbMV0/JRx5RbGFzoVUz2
         E1NA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:content-transfer-encoding
         :in-reply-to:user-agent;
        bh=aYpPZYtqod+fTEVMSorWhJ9m+fKXe1m4+frfAcmvGyw=;
        b=LzDw4PMg4Rae9ct9upbMcvC8sX3FWeEqzJv4fz3ZWnys2kzUAunRVJMOrQ3qaeiVbw
         fUjZxNHMH7NNNXV6i/8cCvVSL4K+InJRTcy4W2mGemHeJWjCv4jPs6LXXXb+I0NYP9DR
         HBmSa/RsV2gND5GzuzyBee98R823P/ByxpK5ZmeS71jtPl1fsyqjGe/ZRQNy7WdHiPDm
         O3AOAEUgeakZANh1OuEtSp7LZLsZ51EbPwEATZzBx/yoA00wMH44mpqAPiMArdRoTT4B
         eISpN+nXPHZVDxDjWep1a6yux1HfUTrr6oVIv1I1hFEwjDM/zguoq6A29U2cxRHwcK84
         AkAg==
X-Gm-Message-State: APjAAAVWWvo7uSTFCHlySkB4VhdSo5D/D/cRnVTPKS7kGOFhSdkHDrYV
	nh/aLF+h8BVOT1yion+gbbmN7w==
X-Google-Smtp-Source: APXvYqxB6NZLC2rrQAg7I6KgD70/5Hu6l4Z9mEKxIX68NL5/RT6fP/bDpg9I56nVuVJ5jZ37fvu3SA==
X-Received: by 2002:a0c:ab49:: with SMTP id i9mr14487677qvb.142.1566307867024;
        Tue, 20 Aug 2019 06:31:07 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id u23sm8481051qkj.98.2019.08.20.06.31.06
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 20 Aug 2019 06:31:06 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1i04E6-0000Y2-5B; Tue, 20 Aug 2019 10:31:06 -0300
Date: Tue, 20 Aug 2019 10:31:06 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Daniel Vetter <daniel.vetter@ffwll.ch>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>,
	DRI Development <dri-devel@lists.freedesktop.org>,
	Intel Graphics Development <intel-gfx@lists.freedesktop.org>,
	Chris Wilson <chris@chris-wilson.co.uk>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Rientjes <rientjes@google.com>,
	=?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
	Michal Hocko <mhocko@suse.com>,
	Christian =?utf-8?B?S8O2bmln?= <christian.koenig@amd.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Daniel Vetter <daniel.vetter@intel.com>
Subject: Re: [PATCH 1/4] mm, notifier: Add a lockdep map for
 invalidate_range_start/end
Message-ID: <20190820133106.GE29246@ziepe.ca>
References: <20190820081902.24815-1-daniel.vetter@ffwll.ch>
 <20190820081902.24815-2-daniel.vetter@ffwll.ch>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20190820081902.24815-2-daniel.vetter@ffwll.ch>
User-Agent: Mutt/1.9.4 (2018-02-28)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 20, 2019 at 10:18:59AM +0200, Daniel Vetter wrote:
> This is a similar idea to the fs_reclaim fake lockdep lock. It's
> fairly easy to provoke a specific notifier to be run on a specific
> range: Just prep it, and then munmap() it.
>=20
> A bit harder, but still doable, is to provoke the mmu notifiers for
> all the various callchains that might lead to them. But both at the
> same time is really hard to reliable hit, especially when you want to
> exercise paths like direct reclaim or compaction, where it's not
> easy to control what exactly will be unmapped.
>=20
> By introducing a lockdep map to tie them all together we allow lockdep
> to see a lot more dependencies, without having to actually hit them
> in a single challchain while testing.
>=20
> On Jason's suggestion this is is rolled out for both
> invalidate_range_start and invalidate_range_end. They both have the
> same calling context, hence we can share the same lockdep map. Note
> that the annotation for invalidate_ranage_start is outside of the
> mm_has_notifiers(), to make sure lockdep is informed about all paths
> leading to this context irrespective of whether mmu notifiers are
> present for a given context. We don't do that on the
> invalidate_range_end side to avoid paying the overhead twice, there
> the lockdep annotation is pushed down behind the mm_has_notifiers()
> check.
>=20
> v2: Use lock_map_acquire/release() like fs_reclaim, to avoid confusion
> with this being a real mutex (Chris Wilson).
>=20
> v3: Rebase on top of Glisse's arg rework.
>=20
> v4: Also annotate invalidate_range_end (Jason Gunthorpe)
> Also annotate invalidate_range_start_nonblock, I somehow missed that
> one in the first version.
>=20
> Cc: Jason Gunthorpe <jgg@ziepe.ca>
> Cc: Chris Wilson <chris@chris-wilson.co.uk>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: David Rientjes <rientjes@google.com>
> Cc: "J=C3=A9r=C3=B4me Glisse" <jglisse@redhat.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: "Christian K=C3=B6nig" <christian.koenig@amd.com>
> Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> Cc: Daniel Vetter <daniel.vetter@ffwll.ch>
> Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>
> Cc: linux-mm@kvack.org
> Signed-off-by: Daniel Vetter <daniel.vetter@intel.com>
> ---
>  include/linux/mmu_notifier.h | 8 ++++++++
>  mm/mmu_notifier.c            | 9 +++++++++
>  2 files changed, 17 insertions(+)

Reviewed-by: Jason Gunthorpe <jgg@mellanox.com>

Jason

