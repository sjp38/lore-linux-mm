Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ECBD7C3A589
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 17:39:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BB84E2063F
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 17:39:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BB84E2063F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8B07E6B02F7; Thu, 15 Aug 2019 13:39:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8614D6B02F8; Thu, 15 Aug 2019 13:39:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 778036B02F9; Thu, 15 Aug 2019 13:39:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0081.hostedemail.com [216.40.44.81])
	by kanga.kvack.org (Postfix) with ESMTP id 5807A6B02F7
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 13:39:28 -0400 (EDT)
Received: from smtpin09.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 1461545BD
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 17:39:28 +0000 (UTC)
X-FDA: 75825374016.09.join52_6fb4154210108
X-HE-Tag: join52_6fb4154210108
X-Filterd-Recvd-Size: 4528
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf41.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 17:39:27 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 500082A09BD;
	Thu, 15 Aug 2019 17:39:26 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.178])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 90D51841D7;
	Thu, 15 Aug 2019 17:39:24 +0000 (UTC)
Date: Thu, 15 Aug 2019 13:39:22 -0400
From: Jerome Glisse <jglisse@redhat.com>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Daniel Vetter <daniel.vetter@ffwll.ch>,
	Michal Hocko <mhocko@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>,
	DRI Development <dri-devel@lists.freedesktop.org>,
	Intel Graphics Development <intel-gfx@lists.freedesktop.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@redhat.com>,
	David Rientjes <rientjes@google.com>,
	Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	Wei Wang <wvw@google.com>,
	Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
	Thomas Gleixner <tglx@linutronix.de>, Jann Horn <jannh@google.com>,
	Feng Tang <feng.tang@intel.com>, Kees Cook <keescook@chromium.org>,
	Randy Dunlap <rdunlap@infradead.org>,
	Daniel Vetter <daniel.vetter@intel.com>
Subject: Re: [PATCH 2/5] kernel.h: Add non_block_start/end()
Message-ID: <20190815173922.GH30916@redhat.com>
References: <20190814202027.18735-3-daniel.vetter@ffwll.ch>
 <20190814134558.fe659b1a9a169c0150c3e57c@linux-foundation.org>
 <20190815084429.GE9477@dhcp22.suse.cz>
 <20190815130415.GD21596@ziepe.ca>
 <CAKMK7uE9zdmBuvxa788ONYky=46GN=5Up34mKDmsJMkir4x7MQ@mail.gmail.com>
 <20190815143759.GG21596@ziepe.ca>
 <CAKMK7uEJQ6mPQaOWbT_6M+55T-dCVbsOxFnMC6KzLAMQNa-RGg@mail.gmail.com>
 <20190815151028.GJ21596@ziepe.ca>
 <CAKMK7uG33FFCGJrDV4-FHT2FWi+Z5SnQ7hoyBQd4hignzm1C-A@mail.gmail.com>
 <20190815173557.GN21596@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20190815173557.GN21596@ziepe.ca>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Thu, 15 Aug 2019 17:39:26 +0000 (UTC)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 15, 2019 at 02:35:57PM -0300, Jason Gunthorpe wrote:
> On Thu, Aug 15, 2019 at 06:25:16PM +0200, Daniel Vetter wrote:
>=20
> > I'm not really well versed in the details of our userptr, but both
> > amdgpu and i915 wait for the gpu to complete from
> > invalidate_range_start. Jerome has at least looked a lot at the amdgp=
u
> > one, so maybe he can explain what exactly it is we're doing ...
>=20
> amdgpu is (wrongly) using hmm for something, I can't really tell what
> it is trying to do. The calls to dma_fence under the
> invalidate_range_start do not give me a good feeling.
>=20
> However, i915 shows all the signs of trying to follow the registration
> cache model, it even has a nice comment in
> i915_gem_userptr_get_pages() explaining that the races it has don't
> matter because it is a user space bug to change the VA mapping in the
> first place. That just screams registration cache to me.
>=20
> So it is fine to run HW that way, but if you do, there is no reason to
> fence inside the invalidate_range end. Just orphan the DMA buffer and
> clean it up & release the page pins when all DMA buffer refs go to
> zero. The next access to that VA should get a new DMA buffer with the
> right mapping.
>=20
> In other words the invalidation should be very simple without
> complicated locking, or wait_event's. Look at hfi1 for example.

This would break the today usage model of uptr and it will
break userspace expectation ie if GPU is writting to that
memory and that memory then the userspace want to make sure
that it will see what the GPU write.

Yes i915 is broken in respect to not having a end notifier
and tracking active invalidation for a range but the GUP
side of thing kind of hide this bug and it shrinks the window
for bad to happen to something so small that i doubt anyone
could ever hit it (still a bug thought).

Cheers,
J=E9r=F4me

