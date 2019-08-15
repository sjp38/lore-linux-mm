Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5BCD2C3A589
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 17:36:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 22DB62084D
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 17:36:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="TEE2VTSv"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 22DB62084D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B4ABE6B02F3; Thu, 15 Aug 2019 13:35:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AFB916B02F4; Thu, 15 Aug 2019 13:35:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9EB686B02F5; Thu, 15 Aug 2019 13:35:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0101.hostedemail.com [216.40.44.101])
	by kanga.kvack.org (Postfix) with ESMTP id 7CEBC6B02F3
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 13:35:59 -0400 (EDT)
Received: from smtpin01.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 2FB28180AD805
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 17:35:59 +0000 (UTC)
X-FDA: 75825365238.01.nut19_51547ab98ed07
X-HE-Tag: nut19_51547ab98ed07
X-Filterd-Recvd-Size: 5670
Received: from mail-qk1-f196.google.com (mail-qk1-f196.google.com [209.85.222.196])
	by imf38.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 17:35:58 +0000 (UTC)
Received: by mail-qk1-f196.google.com with SMTP id u190so2477997qkh.5
        for <linux-mm@kvack.org>; Thu, 15 Aug 2019 10:35:58 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=3I0/JtshV0JYc9v5er9Nyt2RkR0gXgFBErZRF2qt5m0=;
        b=TEE2VTSv3tx1ZS4nODo3IOEMW+jHQ+D+qi1QIiUZkTdg3tRdtrDS1Yi2Ge0OnwlQjy
         9uKji7u3GHzFOTQr/5OvgUSnhcrBXLslyqF2JAqkQ3GgIk6PLNtVym1yiMIGLCNKTOL1
         iQXtVYo5wmF7eZRIICfA54N3DHqUUMZ+9l5FqFEVzN+v0bu03kcn014mCrD0u20coYbC
         eOTlerFgdQ1Hl3pSxKkr16MDtNGjVedbFoafrOTqsODAG2Dy9iAybdLDz91AheE0jhP3
         csOgvcEu4MCFZjOLKT0QXJJsbsK8STjBB7eCxSDOzDzFeZfx8mVvw4ErfTv55+OVi7LQ
         HPJQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=3I0/JtshV0JYc9v5er9Nyt2RkR0gXgFBErZRF2qt5m0=;
        b=OLgkwHB/0gbAJUTBYCtXrBWU2mxcbKAVIh5dbdg3NMsrmp/iQiHfeQFWelE9f2PWmb
         k4IO1DGiE5RAF5qnd60/lNn+E4mg4NDqI/lVNzHEGBR9TXpwVMuaf662jLNLhhX//Tot
         6vqbNxm8uUGf1qKZFA5LDtNGGyXaAzxCpKP2wO6M9LXEq9lyr0Vwo+g52od2RFfNw4WC
         3qEE7APVYB8jKpURlnP7b/ioEWnGcD0RpOAtGY4POCHY+QKz778QX0Nb0rzAkv3SwdCx
         e+XhoKdrlRFBKXTBprd5TAUUlOI5utCVH1pKvbibuSm8hqaUCbofAvb1xZncdnlbdWhR
         sFuQ==
X-Gm-Message-State: APjAAAXNIOEtrnWwTm1+JGm2KPFZCB7bCo0sa55mFcJSnJLd8p3i1EzX
	LE/2C5J4EdiJ0tMFj1AkOKkn+A==
X-Google-Smtp-Source: APXvYqxCT6Z6k6qpPIV0VSEi+Ea/Upm35vjesy1M0E1G5PDQA92PUo48Y+Ame9Jik9oEIwW+jp3Waw==
X-Received: by 2002:ae9:f707:: with SMTP id s7mr5159848qkg.0.1565890558329;
        Thu, 15 Aug 2019 10:35:58 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id e3sm1552304qkg.91.2019.08.15.10.35.57
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 15 Aug 2019 10:35:58 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hyJfJ-0006yS-GO; Thu, 15 Aug 2019 14:35:57 -0300
Date: Thu, 15 Aug 2019 14:35:57 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Daniel Vetter <daniel.vetter@ffwll.ch>
Cc: Michal Hocko <mhocko@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>,
	DRI Development <dri-devel@lists.freedesktop.org>,
	Intel Graphics Development <intel-gfx@lists.freedesktop.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@redhat.com>,
	David Rientjes <rientjes@google.com>,
	Christian =?utf-8?B?S8O2bmln?= <christian.koenig@amd.com>,
	=?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	Wei Wang <wvw@google.com>,
	Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
	Thomas Gleixner <tglx@linutronix.de>, Jann Horn <jannh@google.com>,
	Feng Tang <feng.tang@intel.com>, Kees Cook <keescook@chromium.org>,
	Randy Dunlap <rdunlap@infradead.org>,
	Daniel Vetter <daniel.vetter@intel.com>
Subject: Re: [PATCH 2/5] kernel.h: Add non_block_start/end()
Message-ID: <20190815173557.GN21596@ziepe.ca>
References: <20190814202027.18735-1-daniel.vetter@ffwll.ch>
 <20190814202027.18735-3-daniel.vetter@ffwll.ch>
 <20190814134558.fe659b1a9a169c0150c3e57c@linux-foundation.org>
 <20190815084429.GE9477@dhcp22.suse.cz>
 <20190815130415.GD21596@ziepe.ca>
 <CAKMK7uE9zdmBuvxa788ONYky=46GN=5Up34mKDmsJMkir4x7MQ@mail.gmail.com>
 <20190815143759.GG21596@ziepe.ca>
 <CAKMK7uEJQ6mPQaOWbT_6M+55T-dCVbsOxFnMC6KzLAMQNa-RGg@mail.gmail.com>
 <20190815151028.GJ21596@ziepe.ca>
 <CAKMK7uG33FFCGJrDV4-FHT2FWi+Z5SnQ7hoyBQd4hignzm1C-A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAKMK7uG33FFCGJrDV4-FHT2FWi+Z5SnQ7hoyBQd4hignzm1C-A@mail.gmail.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 15, 2019 at 06:25:16PM +0200, Daniel Vetter wrote:

> I'm not really well versed in the details of our userptr, but both
> amdgpu and i915 wait for the gpu to complete from
> invalidate_range_start. Jerome has at least looked a lot at the amdgpu
> one, so maybe he can explain what exactly it is we're doing ...

amdgpu is (wrongly) using hmm for something, I can't really tell what
it is trying to do. The calls to dma_fence under the
invalidate_range_start do not give me a good feeling.

However, i915 shows all the signs of trying to follow the registration
cache model, it even has a nice comment in
i915_gem_userptr_get_pages() explaining that the races it has don't
matter because it is a user space bug to change the VA mapping in the
first place. That just screams registration cache to me.

So it is fine to run HW that way, but if you do, there is no reason to
fence inside the invalidate_range end. Just orphan the DMA buffer and
clean it up & release the page pins when all DMA buffer refs go to
zero. The next access to that VA should get a new DMA buffer with the
right mapping.

In other words the invalidation should be very simple without
complicated locking, or wait_event's. Look at hfi1 for example.

Jason

