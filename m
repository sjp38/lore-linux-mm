Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.0 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 22C39C31E40
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 06:58:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CA44F2084D
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 06:58:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (1024-bit key) header.d=ffwll.ch header.i=@ffwll.ch header.b="kGKYX8WC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CA44F2084D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ffwll.ch
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5D6B76B0007; Thu, 15 Aug 2019 02:58:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 587846B0008; Thu, 15 Aug 2019 02:58:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4748B6B000A; Thu, 15 Aug 2019 02:58:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0082.hostedemail.com [216.40.44.82])
	by kanga.kvack.org (Postfix) with ESMTP id 215036B0007
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 02:58:35 -0400 (EDT)
Received: from smtpin29.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 939208248AA7
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 06:58:34 +0000 (UTC)
X-FDA: 75823758948.29.tub04_2daee5fa1a458
X-HE-Tag: tub04_2daee5fa1a458
X-Filterd-Recvd-Size: 9213
Received: from mail-ed1-f66.google.com (mail-ed1-f66.google.com [209.85.208.66])
	by imf34.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 06:58:33 +0000 (UTC)
Received: by mail-ed1-f66.google.com with SMTP id p28so1322409edi.3
        for <linux-mm@kvack.org>; Wed, 14 Aug 2019 23:58:33 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ffwll.ch; s=google;
        h=sender:date:from:to:cc:subject:message-id:mail-followup-to
         :references:mime-version:content-disposition:in-reply-to:user-agent;
        bh=9lqqkaS001tXTBszYzeiJH38HEfaSqFOiRWf4hWiQAE=;
        b=kGKYX8WCtIWPm4IRO12hI1D0cjf/mI6eQP72qIiFFGtnNzwCY04Wmo7zjazUdqpw/d
         Del5Qla1OnO++32rcBWEVNsFe4PD3aQALBzRK4Su/mIZ4kIuX0VTEYN8IY+6aVsSvcOZ
         7BJQBjHzNo13izdIP+UvcB7SJ2tHQ6yPSCE5g=
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:sender:date:from:to:cc:subject:message-id
         :mail-followup-to:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=9lqqkaS001tXTBszYzeiJH38HEfaSqFOiRWf4hWiQAE=;
        b=EPC6SYpDzbjhfpOn8LG31RuReREJO5XaDkftd8EGk++S5LSQQsgUFJzCQm64lUoY/c
         9+B3BPpQc6JI/4fkHdeKSB2pVfWWBL/aRxACz9e27eTUVSzyU4sDFBtNblRh/ZXHNrYz
         TRsqUk4biHUrDdLEkK4xfXidWrFG9oSvvFSqE3nv6NgRREtTC4VzKyYrQiKkjor3jdBK
         9B89Ih5j+I6bMlIZRixt6CNW37Bfiv0xOghophj6mmEulvRPS3OQ1ZIf6x+O/wWxk9q5
         K7MRejy48CErJuwVcHjurnzeylf6W4CywYhRmphHYgdBZ6mwiqqYnv84NVjjhFOYcJ2L
         UpRw==
X-Gm-Message-State: APjAAAWmpU3ckKvtdtH+RaNs2wPIKUigPuYIM5YUIE4XQojBlFs5kkao
	Hdh2Nld+hgH112fzkfowHvbHSA==
X-Google-Smtp-Source: APXvYqxywF6ZFPpqpELjFS+YznGqSqHzYzsoNbFwgEupP5iJucMUMFx7LcA8eHspNumjBMO9waYOnw==
X-Received: by 2002:aa7:d981:: with SMTP id u1mr3719744eds.150.1565852312360;
        Wed, 14 Aug 2019 23:58:32 -0700 (PDT)
Received: from phenom.ffwll.local ([2a02:168:569e:0:3106:d637:d723:e855])
        by smtp.gmail.com with ESMTPSA id x11sm252024eju.26.2019.08.14.23.58.30
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 14 Aug 2019 23:58:31 -0700 (PDT)
Date: Thu, 15 Aug 2019 08:58:29 +0200
From: Daniel Vetter <daniel@ffwll.ch>
To: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Daniel Vetter <daniel.vetter@ffwll.ch>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org,
	DRI Development <dri-devel@lists.freedesktop.org>,
	Intel Graphics Development <intel-gfx@lists.freedesktop.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@suse.com>,
	David Rientjes <rientjes@google.com>,
	Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	Wei Wang <wvw@google.com>,
	Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
	Thomas Gleixner <tglx@linutronix.de>, Jann Horn <jannh@google.com>,
	Feng Tang <feng.tang@intel.com>, Kees Cook <keescook@chromium.org>,
	Randy Dunlap <rdunlap@infradead.org>,
	Daniel Vetter <daniel.vetter@intel.com>
Subject: Re: [PATCH 2/5] kernel.h: Add non_block_start/end()
Message-ID: <20190815065829.GA7444@phenom.ffwll.local>
Mail-Followup-To: Jason Gunthorpe <jgg@ziepe.ca>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org,
	DRI Development <dri-devel@lists.freedesktop.org>,
	Intel Graphics Development <intel-gfx@lists.freedesktop.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@suse.com>,
	David Rientjes <rientjes@google.com>,
	Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	Wei Wang <wvw@google.com>,
	Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
	Thomas Gleixner <tglx@linutronix.de>, Jann Horn <jannh@google.com>,
	Feng Tang <feng.tang@intel.com>, Kees Cook <keescook@chromium.org>,
	Randy Dunlap <rdunlap@infradead.org>,
	Daniel Vetter <daniel.vetter@intel.com>
References: <20190814202027.18735-1-daniel.vetter@ffwll.ch>
 <20190814202027.18735-3-daniel.vetter@ffwll.ch>
 <20190814235805.GB11200@ziepe.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190814235805.GB11200@ziepe.ca>
X-Operating-System: Linux phenom 4.19.0-5-amd64 
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Aug 14, 2019 at 08:58:05PM -0300, Jason Gunthorpe wrote:
> On Wed, Aug 14, 2019 at 10:20:24PM +0200, Daniel Vetter wrote:
> > In some special cases we must not block, but there's not a
> > spinlock, preempt-off, irqs-off or similar critical section already
> > that arms the might_sleep() debug checks. Add a non_block_start/end()
> > pair to annotate these.
> > 
> > This will be used in the oom paths of mmu-notifiers, where blocking is
> > not allowed to make sure there's forward progress. Quoting Michal:
> > 
> > "The notifier is called from quite a restricted context - oom_reaper -
> > which shouldn't depend on any locks or sleepable conditionals. The code
> > should be swift as well but we mostly do care about it to make a forward
> > progress. Checking for sleepable context is the best thing we could come
> > up with that would describe these demands at least partially."
> 
> But this describes fs_reclaim_acquire() - is there some reason we are
> conflating fs_reclaim with non-sleeping?

No idea why you tie this into fs_reclaim. We can definitly sleep in there,
and for e.g. kswapd (which also wraps everything in fs_reclaim) we're
event supposed to I thought. To make sure we can get at the last bit of
memory by flushing all the queues and waiting for everything to be cleaned
out.

> ie is there some fundamental difference between the block stack
> sleeping during reclaim while it waits for a driver to write out a
> page and a GPU driver sleeping during OOM while it waits for it's HW
> to fence DMA on a page?
> 
> Fundamentally we have invalidate_range_start() vs invalidate_range()
> as the start() version is able to sleep. If drivers can do their work
> without sleeping then they should be using invalidare_range() instead.
> 
> Thus, it doesn't seem to make any sense to ask a driver that requires a
> sleeping API not to sleep.
> 
> AFAICT what is really going on here is that drivers care about only a
> subset of the VA space, and we want to query the driver if it cares
> about the range proposed to be OOM'd, so we can OOM ranges that are
> do not have SPTEs.
> 
> ie if you look pretty much all drivers do exactly as
> userptr_mn_invalidate_range_start() does, and bail once they detect
> the VA range is of interest.
> 
> So, I'm working on a patch to lift the interval tree into the notifier
> core and then do the VA test OOM needs without bothering the
> driver. Drivers can retain the blocking API they require and OOM can
> work on VA's that don't have SPTEs.

Hm I figured the point of hmm_mirror is to have that interval tree for
everyone (among other things). But yeah lifting to mmu_notifier sounds
like a clean solution for this, but I really have not much clue about why
we even have this for special mode in the oom case. I'm just trying to
increase the odds that drivers hold up their end of the bargain.

> This approach also solves the critical bug in this path:
>   https://lore.kernel.org/linux-mm/20190807191627.GA3008@ziepe.ca/
> 
> And solves a bunch of other bugs in the drivers.
> 
> > Peter also asked whether we want to catch spinlocks on top, but Michal
> > said those are less of a problem because spinlocks can't have an
> > indirect dependency upon the page allocator and hence close the loop
> > with the oom reaper.
> 
> Again, this entirely sounds like fs_reclaim - isn't that exactly what
> it is for?
> 
> I have had on my list a second and very related possible bug. I ran
> into commit 35cfa2b0b491 ("mm/mmu_notifier: allocate mmu_notifier in
> advance") which says that mapping->i_mmap_mutex is under fs_reclaim().
> 
> We do hold i_mmap_rwsem while calling invalidate_range_start():
> 
>  unmap_mapping_pages
>   i_mmap_lock_write(mapping); // ie i_mmap_rwsem
>   unmap_mapping_range_tree
>    unmap_mapping_range_vma
>     zap_page_range_single
>      mmu_notifier_invalidate_range_start
> 
> So, if it is still true that i_mmap_rwsem is under fs_reclaim then
> invalidate_range_start is *always* under fs_reclaim anyhow! (this I do
> not know)
> 
> Thus we should use lockdep to force this and fix all the drivers.
> 
> .. and if we force fs_reclaim always, do we care about blockable
> anymore??

Still not sure what fs_reclaim matters here. One of the later patches
steals the fs_reclaim idea for mmu_notifiers, but that ties together
completely different paths.
-Daniel
-- 
Daniel Vetter
Software Engineer, Intel Corporation
http://blog.ffwll.ch

