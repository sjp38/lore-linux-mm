Return-Path: <SRS0=g7KO=WK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3AEC3C433FF
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 23:58:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E00F820866
	for <linux-mm@archiver.kernel.org>; Wed, 14 Aug 2019 23:58:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="bIdfPpif"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E00F820866
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8E5D16B0003; Wed, 14 Aug 2019 19:58:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 896A16B0005; Wed, 14 Aug 2019 19:58:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7846C6B000A; Wed, 14 Aug 2019 19:58:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0015.hostedemail.com [216.40.44.15])
	by kanga.kvack.org (Postfix) with ESMTP id 505126B0003
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 19:58:08 -0400 (EDT)
Received: from smtpin03.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id F29F88248AA6
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 23:58:07 +0000 (UTC)
X-FDA: 75822699414.03.boat09_cba106878051
X-HE-Tag: boat09_cba106878051
X-Filterd-Recvd-Size: 7345
Received: from mail-qt1-f196.google.com (mail-qt1-f196.google.com [209.85.160.196])
	by imf09.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 14 Aug 2019 23:58:07 +0000 (UTC)
Received: by mail-qt1-f196.google.com with SMTP id j15so572149qtl.13
        for <linux-mm@kvack.org>; Wed, 14 Aug 2019 16:58:07 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=FuSmTDQh/a+OrOwuynD6gKCzqpRnsaVG3w7wfpm3wqA=;
        b=bIdfPpifc5Df9ZyMbaAk6YR1Vm3aqYYmMsJc0qwv0DToMlRhj/7B84jNM0/7ULt0L/
         iPW3be0SBOV+BK2Qq+r3HGbp7n+Ruf2KfYxPY7vCJp7IP2MVW6KkmPRqvpHfiaudOeEA
         8XRBeYf9Jvlsy4GSSmyOXgDr+1GrEBlEw5Rb2ZSzcOZLkwbEmk8gQhI8Fk1vnvmp9UPM
         aWm+btPas4OlWBb79U1jxtWQ9X1VBjwE7Lwmpo54l5E5bq4gRjI0aEzdE+q8KotxnPb0
         FG86Zjs2dElwOvmLJRDFrE3H0a/YBujkY9Fwqq3EXsGzEM0lRNI9ELgfB11P/lPn/yLd
         ypYA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=FuSmTDQh/a+OrOwuynD6gKCzqpRnsaVG3w7wfpm3wqA=;
        b=F9apyLEF1wlpkNnFpAp61gjkzf4BV4tCsGo1rvFn4cxcum01/XUfDmM69Ww4g/KlTm
         Un+5Ai73RiRSOjFfA4DQbfvB9R4sNmvsB4tPjrOw++uDTUjK4w84NoDCdbDoH02z1+Qe
         Yvd17N7Bw90xLPYHNqtU6eu7hyb5qSOM3VQCBvfHUJVj9ob5Yo19hD4a1ymvQroTg3Z4
         oNDMjKAL/dVoKouIf6IvEEqmfLovgIl2qt7NVNPLPOnn/UHxPDI60exAxPsdHfRG/pcf
         1wUtNuRYf0ao2bjY2LGomXWpVQpHuvMrk1CpWTN8h8Il/29CJUIVv+BAPtcflGVtSWh7
         mF0Q==
X-Gm-Message-State: APjAAAU/9LtinnMMiRADtR2vjV/fm3x6prQs+dPuDt1uvX3ooaoi+cKS
	chhpCTZjRDMU/MbSPwrdc0sMUA==
X-Google-Smtp-Source: APXvYqxbOcBJLerQ1ntgU+4v2Av22ce7b8GmE+kj/TlbSxhhrGXkYlwnkE0HmVlmbhH1xrGkT1mvng==
X-Received: by 2002:ac8:1605:: with SMTP id p5mr1674140qtj.79.1565827086773;
        Wed, 14 Aug 2019 16:58:06 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id r19sm542639qtm.44.2019.08.14.16.58.06
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 14 Aug 2019 16:58:06 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hy39Z-0003Tg-WA; Wed, 14 Aug 2019 20:58:06 -0300
Date: Wed, 14 Aug 2019 20:58:05 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Daniel Vetter <daniel.vetter@ffwll.ch>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org,
	DRI Development <dri-devel@lists.freedesktop.org>,
	Intel Graphics Development <intel-gfx@lists.freedesktop.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@suse.com>,
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
Message-ID: <20190814235805.GB11200@ziepe.ca>
References: <20190814202027.18735-1-daniel.vetter@ffwll.ch>
 <20190814202027.18735-3-daniel.vetter@ffwll.ch>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190814202027.18735-3-daniel.vetter@ffwll.ch>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 14, 2019 at 10:20:24PM +0200, Daniel Vetter wrote:
> In some special cases we must not block, but there's not a
> spinlock, preempt-off, irqs-off or similar critical section already
> that arms the might_sleep() debug checks. Add a non_block_start/end()
> pair to annotate these.
> 
> This will be used in the oom paths of mmu-notifiers, where blocking is
> not allowed to make sure there's forward progress. Quoting Michal:
> 
> "The notifier is called from quite a restricted context - oom_reaper -
> which shouldn't depend on any locks or sleepable conditionals. The code
> should be swift as well but we mostly do care about it to make a forward
> progress. Checking for sleepable context is the best thing we could come
> up with that would describe these demands at least partially."

But this describes fs_reclaim_acquire() - is there some reason we are
conflating fs_reclaim with non-sleeping?

ie is there some fundamental difference between the block stack
sleeping during reclaim while it waits for a driver to write out a
page and a GPU driver sleeping during OOM while it waits for it's HW
to fence DMA on a page?

Fundamentally we have invalidate_range_start() vs invalidate_range()
as the start() version is able to sleep. If drivers can do their work
without sleeping then they should be using invalidare_range() instead.

Thus, it doesn't seem to make any sense to ask a driver that requires a
sleeping API not to sleep.

AFAICT what is really going on here is that drivers care about only a
subset of the VA space, and we want to query the driver if it cares
about the range proposed to be OOM'd, so we can OOM ranges that are
do not have SPTEs.

ie if you look pretty much all drivers do exactly as
userptr_mn_invalidate_range_start() does, and bail once they detect
the VA range is of interest.

So, I'm working on a patch to lift the interval tree into the notifier
core and then do the VA test OOM needs without bothering the
driver. Drivers can retain the blocking API they require and OOM can
work on VA's that don't have SPTEs.

This approach also solves the critical bug in this path:
  https://lore.kernel.org/linux-mm/20190807191627.GA3008@ziepe.ca/

And solves a bunch of other bugs in the drivers.

> Peter also asked whether we want to catch spinlocks on top, but Michal
> said those are less of a problem because spinlocks can't have an
> indirect dependency upon the page allocator and hence close the loop
> with the oom reaper.

Again, this entirely sounds like fs_reclaim - isn't that exactly what
it is for?

I have had on my list a second and very related possible bug. I ran
into commit 35cfa2b0b491 ("mm/mmu_notifier: allocate mmu_notifier in
advance") which says that mapping->i_mmap_mutex is under fs_reclaim().

We do hold i_mmap_rwsem while calling invalidate_range_start():

 unmap_mapping_pages
  i_mmap_lock_write(mapping); // ie i_mmap_rwsem
  unmap_mapping_range_tree
   unmap_mapping_range_vma
    zap_page_range_single
     mmu_notifier_invalidate_range_start

So, if it is still true that i_mmap_rwsem is under fs_reclaim then
invalidate_range_start is *always* under fs_reclaim anyhow! (this I do
not know)

Thus we should use lockdep to force this and fix all the drivers.

.. and if we force fs_reclaim always, do we care about blockable
anymore??

Jason

