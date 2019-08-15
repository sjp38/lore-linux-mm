Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_SANE_1 autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0EC5FC3A589
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 16:32:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CF64520578
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 16:32:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CF64520578
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 699416B02C0; Thu, 15 Aug 2019 12:32:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 649316B02C2; Thu, 15 Aug 2019 12:32:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 537E26B02C3; Thu, 15 Aug 2019 12:32:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0045.hostedemail.com [216.40.44.45])
	by kanga.kvack.org (Postfix) with ESMTP id 2C99F6B02C0
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 12:32:46 -0400 (EDT)
Received: from smtpin30.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id C024C181AC9B4
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 16:32:45 +0000 (UTC)
X-FDA: 75825205890.30.act18_6f59ed878842c
X-HE-Tag: act18_6f59ed878842c
X-Filterd-Recvd-Size: 5576
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf24.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 16:32:45 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id C67853E2D3;
	Thu, 15 Aug 2019 16:32:42 +0000 (UTC)
Received: from redhat.com (unknown [10.20.6.178])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id A8BCB17AD1;
	Thu, 15 Aug 2019 16:32:40 +0000 (UTC)
Date: Thu, 15 Aug 2019 12:32:38 -0400
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
Message-ID: <20190815163238.GA30781@redhat.com>
References: <20190814202027.18735-1-daniel.vetter@ffwll.ch>
 <20190814202027.18735-3-daniel.vetter@ffwll.ch>
 <20190814134558.fe659b1a9a169c0150c3e57c@linux-foundation.org>
 <20190815084429.GE9477@dhcp22.suse.cz>
 <20190815130415.GD21596@ziepe.ca>
 <CAKMK7uE9zdmBuvxa788ONYky=46GN=5Up34mKDmsJMkir4x7MQ@mail.gmail.com>
 <20190815143759.GG21596@ziepe.ca>
 <CAKMK7uEJQ6mPQaOWbT_6M+55T-dCVbsOxFnMC6KzLAMQNa-RGg@mail.gmail.com>
 <20190815151028.GJ21596@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20190815151028.GJ21596@ziepe.ca>
User-Agent: Mutt/1.11.3 (2019-02-01)
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.30]); Thu, 15 Aug 2019 16:32:43 +0000 (UTC)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 15, 2019 at 12:10:28PM -0300, Jason Gunthorpe wrote:
> On Thu, Aug 15, 2019 at 04:43:38PM +0200, Daniel Vetter wrote:
>=20
> > You have to wait for the gpu to finnish current processing in
> > invalidate_range_start. Otherwise there's no point to any of this
> > really. So the wait_event/dma_fence_wait are unavoidable really.
>=20
> I don't envy your task :|
>=20
> But, what you describe sure sounds like a 'registration cache' model,
> not the 'shadow pte' model of coherency.
>=20
> The key difference is that a regirstationcache is allowed to become
> incoherent with the VMA's because it holds page pins. It is a
> programming bug in userspace to change VA mappings via mmap/munmap/etc
> while the device is working on that VA, but it does not harm system
> integrity because of the page pin.
>=20
> The cache ensures that each initiated operation sees a DMA setup that
> matches the current VA map when the operation is initiated and allows
> expensive device DMA setups to be re-used.
>=20
> A 'shadow pte' model (ie hmm) *really* needs device support to
> directly block DMA access - ie trigger 'device page fault'. ie the
> invalidate_start should inform the device to enter a fault mode and
> that is it.  If the device can't do that, then the driver probably
> shouldn't persue this level of coherency. The driver would quickly get
> into the messy locking problems like dma_fence_wait from a notifier.

I think here we do not agree on the hardware requirement. For GPU
we will always need to be able to wait for some GPU fence from inside
the notifier callback, there is just no way around that for many of
the GPUs today (i do not see any indication of that changing).

Driver should avoid lock complexity by using wait queue so that the
driver notifier callback can wait without having to hold some driver
lock. However there will be at least one lock needed to update the
internal driver state for the range being invalidated. That lock is
just the device driver page table lock for the GPU page table
associated with the mm_struct. In all GPU driver so far it is a short
lived lock and nothing blocking is done while holding it (it is just
about updating page table directory really wether it is filling it or
clearing it).


>=20
> It is important to identify what model you are going for as defining a
> 'registration cache' coherence expectation allows the driver to skip
> blocking in invalidate_range_start. All it does is invalidate the
> cache so that future operations pick up the new VA mapping.
>=20
> Intel's HFI RDMA driver uses this model extensively, and I think it is
> well proven, within some limitations of course.
>=20
> At least, 'registration cache' is the only use model I know of where
> it is acceptable to skip invalidate_range_end.

Here GPU are not in the registration cache model, i know it might looks
like it because of GUP but GUP was use just because hmm did not exist
at the time.

Cheers,
J=E9r=F4me

