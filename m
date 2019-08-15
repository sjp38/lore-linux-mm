Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2E7FEC3A59C
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 13:12:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E84562133F
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 13:12:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=ffwll.ch header.i=@ffwll.ch header.b="Za9fYZAv"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E84562133F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ffwll.ch
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 61CE26B027B; Thu, 15 Aug 2019 09:12:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5CDDB6B027C; Thu, 15 Aug 2019 09:12:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4BBBF6B027D; Thu, 15 Aug 2019 09:12:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0226.hostedemail.com [216.40.44.226])
	by kanga.kvack.org (Postfix) with ESMTP id 23DC26B027B
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 09:12:29 -0400 (EDT)
Received: from smtpin25.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id C53841F1A
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 13:12:28 +0000 (UTC)
X-FDA: 75824701176.25.blade54_6cdfe7c49ad4d
X-HE-Tag: blade54_6cdfe7c49ad4d
X-Filterd-Recvd-Size: 5369
Received: from mail-ot1-f67.google.com (mail-ot1-f67.google.com [209.85.210.67])
	by imf33.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 13:12:28 +0000 (UTC)
Received: by mail-ot1-f67.google.com with SMTP id k18so5754888otr.3
        for <linux-mm@kvack.org>; Thu, 15 Aug 2019 06:12:27 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ffwll.ch; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=nLAvE7lDJNY/2hXIcylLI9QM83e4RDXFU2y4iIE01K4=;
        b=Za9fYZAvz38c7q5/yD99Bw30IvGPgKhHThVM4vKevIWU3/BW35bi+F3ppSbkTaFkbT
         fo2CpvHM7cVjqc50yRgI9kWHHLUpxwV9lKj2e5yAkPWwg/XLsgOFJ9+5aRlUooRkXMat
         8A59WCTr5lrTYXQcbNjUgSTq+i4lJG3Axdh94=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:mime-version:references:in-reply-to:from:date
         :message-id:subject:to:cc;
        bh=nLAvE7lDJNY/2hXIcylLI9QM83e4RDXFU2y4iIE01K4=;
        b=eOVLrlkgTpO20/VAwbvQ2CslpEkDY2XKhfOQahpgZqquD8JEKMjQSGoOf3xM2UgvmH
         68m/U9ONfJGGSCqtBhyl1JjWf1Ho2HsKfYVOr8A33Z08fL6M4w8tohiCUm8j4rQap3ur
         ZGUkEqFp3x8LU2Fy4dd+ZwpQ2PsOHSjSEd4rwZQVGYovge2q9oWh6svOhVjeGlXrYNmR
         ZpSaalhX5vlo4G7W7bKG0a1p+rA00dnyOF0Y2M5zPUICZ9UAjxj/lCHPnu9uRk40SwbB
         e4uHGTeoYx2R5nQW+S5s3gBEG8MbmbNIFORh4K0zgeARBZBV68JZnkmX3UpmkCt3vguV
         WG2g==
X-Gm-Message-State: APjAAAWbTzYShzG2NieCkPw/vOQZtau48tFc5hQnPrbq+AaTe9NF8/LV
	v3v8w9oKedKii/l9Bv3tdDk47f0fJGK+Q2rLwU+yaw==
X-Google-Smtp-Source: APXvYqwb4/fPJEfbvz7yWzpngUJACAlVMwrTaPlMWn6ej36UzkLB2ub99QrSaO1zkI7AqPQMI7LKYD8gIiKyzGjESHY=
X-Received: by 2002:a9d:7cc9:: with SMTP id r9mr3688645otn.188.1565874747163;
 Thu, 15 Aug 2019 06:12:27 -0700 (PDT)
MIME-Version: 1.0
References: <20190814202027.18735-1-daniel.vetter@ffwll.ch>
 <20190814202027.18735-3-daniel.vetter@ffwll.ch> <20190814134558.fe659b1a9a169c0150c3e57c@linux-foundation.org>
 <20190815084429.GE9477@dhcp22.suse.cz> <20190815130415.GD21596@ziepe.ca>
In-Reply-To: <20190815130415.GD21596@ziepe.ca>
From: Daniel Vetter <daniel.vetter@ffwll.ch>
Date: Thu, 15 Aug 2019 15:12:11 +0200
Message-ID: <CAKMK7uE9zdmBuvxa788ONYky=46GN=5Up34mKDmsJMkir4x7MQ@mail.gmail.com>
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

On Thu, Aug 15, 2019 at 3:04 PM Jason Gunthorpe <jgg@ziepe.ca> wrote:
>
> On Thu, Aug 15, 2019 at 10:44:29AM +0200, Michal Hocko wrote:
>
> > As the oom reaper is the primary guarantee of the oom handling forward
> > progress it cannot be blocked on anything that might depend on blockable
> > memory allocations. These are not really easy to track because they
> > might be indirect - e.g. notifier blocks on a lock which other context
> > holds while allocating memory or waiting for a flusher that needs memory
> > to perform its work.
>
> But lockdep *does* track all this and fs_reclaim_acquire() was created
> to solve exactly this problem.
>
> fs_reclaim is a lock and it flows through all the usual lockdep
> schemes like any other lock. Any time the page allocator wants to do
> something the would deadlock with reclaim it takes the lock.
>
> Failure is expressed by a deadlock cycle in the lockdep map, and
> lockdep can handle arbitary complexity through layers of locks, work
> queues, threads, etc.
>
> What is missing?

Lockdep doens't seen everything by far. E.g. a wait_event will be
caught by the annotations here, but not by lockdep. Plus lockdep does
not see through the wait_event, and doesn't realize if e.g. that event
will never signal because the worker is part of the deadlock loop.
cross-release was supposed to fix that, but seems like that will never
land.

And since we're talking about mmu notifiers here and gpus/dma engines.
We have dma_fence_wait, which can wait for any hw/driver in the system
that takes part in shared/zero-copy buffer processing. Which at least
on the graphics side is everything. This pulls in enormous amounts of
deadlock potential that lockdep simply is blind about and will never
see.

Arming might_sleep catches them all.

Cheers, Daniel

PS: Don't ask me about why we need these semantics for oom_reaper,
like I said just trying to follow the rules.
-- 
Daniel Vetter
Software Engineer, Intel Corporation
+41 (0) 79 365 57 48 - http://blog.ffwll.ch

