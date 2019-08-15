Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6C3ADC3A59C
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 14:12:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 221B6208C2
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 14:12:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="XeuqQCC7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 221B6208C2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 999B06B028A; Thu, 15 Aug 2019 10:12:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9232A6B028C; Thu, 15 Aug 2019 10:12:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7EA1D6B028D; Thu, 15 Aug 2019 10:12:22 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0049.hostedemail.com [216.40.44.49])
	by kanga.kvack.org (Postfix) with ESMTP id 550196B028A
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 10:12:22 -0400 (EDT)
Received: from smtpin08.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id E18F5181AC9AE
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 14:12:21 +0000 (UTC)
X-FDA: 75824852082.08.dolls64_31ab26b747b47
X-HE-Tag: dolls64_31ab26b747b47
X-Filterd-Recvd-Size: 8507
Received: from mail-qk1-f193.google.com (mail-qk1-f193.google.com [209.85.222.193])
	by imf48.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 14:12:21 +0000 (UTC)
Received: by mail-qk1-f193.google.com with SMTP id m2so1878676qki.12
        for <linux-mm@kvack.org>; Thu, 15 Aug 2019 07:12:21 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=x9tHuYoDj493ySsdiocBgo6BvbYr3tE408m35OPfD4Q=;
        b=XeuqQCC74y0Tv1RcnQ+QEVxSfwBYVcbFQBv+jHQag9nVoOXYoudI2lsh2oUCEAr39H
         sOBQIHpCJGpf7SZDnsCbABopShyqJF2q2pi6SScyiS2HfIeCvK099//uePU5aMlLfWT6
         9rT/cI5D9uxh84+vzkj7b39A9JCbigiI8u5l63sz2xgiIZS4oQhkLKvvXrLyOi/jHouS
         FHbctFaUe8dq9V6Xp87qmVqN+IWfrjgvVxMfluoX3mjYCvUeczlqt9UvXBmeMyoUR00/
         t5fYmPRvwnODhoTvJWr3AELdv5sIvrNPS63oJojBRQ8h+bdOj03joAvRyD4cBFwQn3n0
         vq0g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=x9tHuYoDj493ySsdiocBgo6BvbYr3tE408m35OPfD4Q=;
        b=P52fSThkFXb6OvRXkhjRksNmGB2fUoEFo527XXcFwsRJT+Ujq7G0P9p6IVA//Npwpj
         lerpkCHTALcdYFpYUvJyiSqkz+95psykLt4bCksuQZeLnlSr90O/bzGHAhRcYyp8Bt3P
         D/r4qfbvTYx3fk0LuQbeKLRHNkjJJQsYVcM3Kg9x7W3LTC9JOoVB7hseYBVbUdaARRNi
         6lFYP6e7aLKviUAC4tdQRQmYm4iCTAzCOQ3KoNqR8JN8PLwWRxYRwI1FAEasRUMOR995
         EFH7j3djEtIxiFAwP054HNOudXaR0cu61/d/b7OFltB2G0bRJWbDPGyF/ZBuf6A4mVPD
         Us1A==
X-Gm-Message-State: APjAAAX8Mom+4bb6acbrQ4V0RoQRPyfzZFKtz0QFxUiZT5fUC8AsNwvo
	DkGzZo7aIlztPJIYFKrtgA0Kbw==
X-Google-Smtp-Source: APXvYqz16XhS3FDKKD5LBLAsMVIBRO6xvZ5cmQP2Rz9DeNPuZ4bmBJXLkXIkrLSg+KeUbMTyo0lWcg==
X-Received: by 2002:ae9:f812:: with SMTP id x18mr4132770qkh.290.1565878340460;
        Thu, 15 Aug 2019 07:12:20 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id o201sm1475995qka.14.2019.08.15.07.12.19
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 15 Aug 2019 07:12:20 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hyGUF-0004xm-IP; Thu, 15 Aug 2019 11:12:19 -0300
Date: Thu, 15 Aug 2019 11:12:19 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Michal Hocko <mhocko@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org,
	DRI Development <dri-devel@lists.freedesktop.org>,
	Intel Graphics Development <intel-gfx@lists.freedesktop.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
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
Message-ID: <20190815141219.GF21596@ziepe.ca>
References: <20190814202027.18735-1-daniel.vetter@ffwll.ch>
 <20190814202027.18735-3-daniel.vetter@ffwll.ch>
 <20190814235805.GB11200@ziepe.ca>
 <20190815065829.GA7444@phenom.ffwll.local>
 <20190815122344.GA21596@ziepe.ca>
 <20190815132127.GI9477@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190815132127.GI9477@dhcp22.suse.cz>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 15, 2019 at 03:21:27PM +0200, Michal Hocko wrote:
> On Thu 15-08-19 09:23:44, Jason Gunthorpe wrote:
> > On Thu, Aug 15, 2019 at 08:58:29AM +0200, Daniel Vetter wrote:
> > > On Wed, Aug 14, 2019 at 08:58:05PM -0300, Jason Gunthorpe wrote:
> > > > On Wed, Aug 14, 2019 at 10:20:24PM +0200, Daniel Vetter wrote:
> > > > > In some special cases we must not block, but there's not a
> > > > > spinlock, preempt-off, irqs-off or similar critical section already
> > > > > that arms the might_sleep() debug checks. Add a non_block_start/end()
> > > > > pair to annotate these.
> > > > > 
> > > > > This will be used in the oom paths of mmu-notifiers, where blocking is
> > > > > not allowed to make sure there's forward progress. Quoting Michal:
> > > > > 
> > > > > "The notifier is called from quite a restricted context - oom_reaper -
> > > > > which shouldn't depend on any locks or sleepable conditionals. The code
> > > > > should be swift as well but we mostly do care about it to make a forward
> > > > > progress. Checking for sleepable context is the best thing we could come
> > > > > up with that would describe these demands at least partially."
> > > > 
> > > > But this describes fs_reclaim_acquire() - is there some reason we are
> > > > conflating fs_reclaim with non-sleeping?
> > > 
> > > No idea why you tie this into fs_reclaim. We can definitly sleep in there,
> > > and for e.g. kswapd (which also wraps everything in fs_reclaim) we're
> > > event supposed to I thought. To make sure we can get at the last bit of
> > > memory by flushing all the queues and waiting for everything to be cleaned
> > > out.
> > 
> > AFAIK the point of fs_reclaim is to prevent "indirect dependency upon
> > the page allocator" ie a justification that was given this !blockable
> > stuff.
> > 
> > For instance:
> > 
> >   fs_reclaim_acquire()
> >   kmalloc(GFP_KERNEL) <- lock dep assertion
> > 
> > And further, Michal's concern about indirectness through locks is also
> > handled by lockdep:
> > 
> >        CPU0                                 CPU1
> >                                         mutex_lock()
> >                                         kmalloc(GFP_KERNEL)
> >                                         mutex_unlock()
> >   fs_reclaim_acquire()
> >   mutex_lock() <- lock dep assertion
> > 
> > In other words, to prevent recursion into the page allocator you use
> > fs_reclaim_acquire(), and lockdep verfies it in its usual robust way.
> 
> fs_reclaim_acquire is about FS/IO recursions IIUC. We are talking about
> any !GFP_NOWAIT allocation context here and any {in}direct dependency on
> it. 

AFAIK 'GFP_NOWAIT' is characterized by the lack of __GFP_FS and
__GFP_DIRECT_RECLAIM..

This matches the existing test in __need_fs_reclaim() - so if you are
OK with GFP_NOFS, aka __GFP_IO which triggers try_to_compact_pages(),
allocations during OOM, then I think fs_reclaim already matches what
you described?

> Whether fs_reclaim_acquire can be reused for that I do not know
> because I am not familiar with the lockdep machinery enough

Well, if fs_reclaim is not already testing the flags you want, then we
could add another lockdep map that does. The basic principle is the
same, if you want to detect and prevent recursion into the allocator
under certain GFP flags then then AFAIK lockdep is the best tool we
have.

> No, non-blocking is a very coarse approximation of what we really need.
> But it should give us even a stronger condition. Essentially any sleep
> other than a preemption shouldn't be allowed in that context.

But it is a nonsense API to give the driver invalidate_range_start,
the blocking alternative to the non-blocking invalidate_range and then
demand it to be non-blocking.

Inspecting the code, no drivers are actually able to progress their
side in non-blocking mode.

The best we got was drivers tested the VA range and returned success
if they had no interest. Which is a big win to be sure, but it looks
like getting any more is not really posssible.

However, we could (probably even should) make the drivers fs_reclaim
safe.

If that is enough to guarantee progress of OOM, then lets consider
something like using current_gfp_context() to force PF_MEMALLOC_NOFS
allocation behavior on the driver callback and lockdep to try and keep
pushing on the the debugging, and dropping !blocking.

Jason

