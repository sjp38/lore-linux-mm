Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3E069C41514
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 14:43:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EA3F520644
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 14:43:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=ffwll.ch header.i=@ffwll.ch header.b="JYRuFfn7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EA3F520644
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ffwll.ch
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 84B086B0294; Thu, 15 Aug 2019 10:43:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7FA466B0296; Thu, 15 Aug 2019 10:43:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 710E66B0297; Thu, 15 Aug 2019 10:43:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0042.hostedemail.com [216.40.44.42])
	by kanga.kvack.org (Postfix) with ESMTP id 52C406B0294
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 10:43:51 -0400 (EDT)
Received: from smtpin29.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id F26D48248AAA
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 14:43:50 +0000 (UTC)
X-FDA: 75824931420.29.tin18_2187520df4a4b
X-HE-Tag: tin18_2187520df4a4b
X-Filterd-Recvd-Size: 6587
Received: from mail-oi1-f196.google.com (mail-oi1-f196.google.com [209.85.167.196])
	by imf10.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 14:43:50 +0000 (UTC)
Received: by mail-oi1-f196.google.com with SMTP id k22so2234032oiw.11
        for <linux-mm@kvack.org>; Thu, 15 Aug 2019 07:43:50 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ffwll.ch; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=EcYg2sxDc/ZPh1T6muHTeyf6D7+2ZcuVsE1FpQg6dIU=;
        b=JYRuFfn7Urv5lm2qIS15ol2FS8DwFIVG8OmWWYMrXmD0Y8R7ysGKlNMvt3KB9qcDzN
         a6Kx7zNWcIphDglLEOAwkTDGtkZEST11XQuWmWBPoVjWS+zZWiun6XIXVgDPHSeyw+S6
         Mixv9rxX3YTPc7/9YynJMiIFHb7t7+ZPgoLpg=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=EcYg2sxDc/ZPh1T6muHTeyf6D7+2ZcuVsE1FpQg6dIU=;
        b=WwpN6zDJjFFPIJ++E92A3Lz+uEvZpG1lk2vC70DUWRysymG5ps0CYm6QfB8bGq/XXU
         Si2MedJmBu4MDVQMcqneKeYQSZh/j4u3B4OdYuf5e8ctZFrysq+ZTMBSMHzgSacB2Nhi
         bV/kjMfAg4kpXIeJwGgjhZl7mt1/+nAoFu2HKfvJWQhP3lCrEJL1CdBsJ727ckDTa7Gt
         kx3+00mgw/B5rsh54QR8Ta7iYiXTl7cbfP6Ldcn0P9LBO+95i4cElCaPep5EK0xAIkgR
         QD/cLVTBSljlLjYXv756G2zyJMjI4GzJ3gHUmBfbIEGhCZrqlm6RaMK1RV42jnBDWxgH
         neSQ==
X-Gm-Message-State: APjAAAXsAp6Ux7dRL3DU+SWrUARUpDN81DUCRAo1O9t3CDUEoWbAC6FG
	ictCVipDnUTn9mW0b19ifRks/T6vMNaNmAcJTKwPCA==
X-Google-Smtp-Source: APXvYqySm/Ahp86UOdMXb+iRgyDRu4sKHNQjbABa4M9MuTxMEzBGIBaeNRuX3C9mf0zipUFJG00ZJ30GOlZewnICp5Q=
X-Received: by 2002:a54:4f89:: with SMTP id g9mr1910952oiy.110.1565880229376;
 Thu, 15 Aug 2019 07:43:49 -0700 (PDT)
MIME-Version: 1.0
References: <20190814202027.18735-1-daniel.vetter@ffwll.ch>
 <20190814202027.18735-3-daniel.vetter@ffwll.ch> <20190814134558.fe659b1a9a169c0150c3e57c@linux-foundation.org>
 <20190815084429.GE9477@dhcp22.suse.cz> <20190815130415.GD21596@ziepe.ca>
 <CAKMK7uE9zdmBuvxa788ONYky=46GN=5Up34mKDmsJMkir4x7MQ@mail.gmail.com> <20190815143759.GG21596@ziepe.ca>
In-Reply-To: <20190815143759.GG21596@ziepe.ca>
From: Daniel Vetter <daniel.vetter@ffwll.ch>
Date: Thu, 15 Aug 2019 16:43:38 +0200
Message-ID: <CAKMK7uEJQ6mPQaOWbT_6M+55T-dCVbsOxFnMC6KzLAMQNa-RGg@mail.gmail.com>
Subject: Re: [PATCH 2/5] kernel.h: Add non_block_start/end()
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, 
	LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, 
	DRI Development <dri-devel@lists.freedesktop.org>, 
	Intel Graphics Development <intel-gfx@lists.freedesktop.org>, Peter Zijlstra <peterz@infradead.org>, 
	Ingo Molnar <mingo@redhat.com>, David Rientjes <rientjes@google.com>, 
	=?UTF-8?Q?Christian_K=C3=B6nig?= <christian.koenig@amd.com>, 
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	Masahiro Yamada <yamada.masahiro@socionext.com>, Wei Wang <wvw@google.com>, 
	Andy Shevchenko <andriy.shevchenko@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, 
	Jann Horn <jannh@google.com>, Feng Tang <feng.tang@intel.com>, 
	Kees Cook <keescook@chromium.org>, Randy Dunlap <rdunlap@infradead.org>, 
	Daniel Vetter <daniel.vetter@intel.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 15, 2019 at 4:38 PM Jason Gunthorpe <jgg@ziepe.ca> wrote:
>
> On Thu, Aug 15, 2019 at 03:12:11PM +0200, Daniel Vetter wrote:
> > On Thu, Aug 15, 2019 at 3:04 PM Jason Gunthorpe <jgg@ziepe.ca> wrote:
> > >
> > > On Thu, Aug 15, 2019 at 10:44:29AM +0200, Michal Hocko wrote:
> > >
> > > > As the oom reaper is the primary guarantee of the oom handling forward
> > > > progress it cannot be blocked on anything that might depend on blockable
> > > > memory allocations. These are not really easy to track because they
> > > > might be indirect - e.g. notifier blocks on a lock which other context
> > > > holds while allocating memory or waiting for a flusher that needs memory
> > > > to perform its work.
> > >
> > > But lockdep *does* track all this and fs_reclaim_acquire() was created
> > > to solve exactly this problem.
> > >
> > > fs_reclaim is a lock and it flows through all the usual lockdep
> > > schemes like any other lock. Any time the page allocator wants to do
> > > something the would deadlock with reclaim it takes the lock.
> > >
> > > Failure is expressed by a deadlock cycle in the lockdep map, and
> > > lockdep can handle arbitary complexity through layers of locks, work
> > > queues, threads, etc.
> > >
> > > What is missing?
> >
> > Lockdep doens't seen everything by far. E.g. a wait_event will be
> > caught by the annotations here, but not by lockdep.
>
> Sure, but the wait_event might be OK if its progress isn't contingent
> on fs_reclaim, ie triggered from interrupt, so why ban it?

For normal notifiers sure (but lockdep won't help you proof that at
all). For oom_reaper apparently not, but that's really Michal's thing,
I have not much idea about that.

> > And since we're talking about mmu notifiers here and gpus/dma engines.
> > We have dma_fence_wait, which can wait for any hw/driver in the system
> > that takes part in shared/zero-copy buffer processing. Which at least
> > on the graphics side is everything. This pulls in enormous amounts of
> > deadlock potential that lockdep simply is blind about and will never
> > see.
>
> It seems very risky to entagle a notifier widely like that.

That's why I've looked into all possible ways to annotate them with
debug infrastructure.

> It looks pretty sure that notifiers are fs_reclaim, so at a minimum
> that wait_event can't be contingent on anything that is doing
> GFP_KERNEL or it will deadlock - and blockable doesn't make that sleep
> safe.
>
> Avoiding an uncertain wait_event under notifiers would seem to be the
> only reasonable design here..

You have to wait for the gpu to finnish current processing in
invalidate_range_start. Otherwise there's no point to any of this
really. So the wait_event/dma_fence_wait are unavoidable really.

That's also why I'm throwing in the lockdep annotation on top, and why
it would be really nice if we somehow can get the cross-release work
landed. But it looks like all the people who could make it happen are
busy with smeltdown :-/
-Daniel
-- 
Daniel Vetter
Software Engineer, Intel Corporation
+41 (0) 79 365 57 48 - http://blog.ffwll.ch

