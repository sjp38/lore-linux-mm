Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A902DC3A589
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 16:56:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 52EA7206C1
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 16:56:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="l/2uXRd4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 52EA7206C1
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D647B6B02D4; Thu, 15 Aug 2019 12:56:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D15666B02D6; Thu, 15 Aug 2019 12:56:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C05076B02D7; Thu, 15 Aug 2019 12:56:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0113.hostedemail.com [216.40.44.113])
	by kanga.kvack.org (Postfix) with ESMTP id A1AD06B02D4
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 12:56:33 -0400 (EDT)
Received: from smtpin03.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 4B5E3181AC9B4
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 16:56:33 +0000 (UTC)
X-FDA: 75825265866.03.gun50_1c0cbba46370c
X-HE-Tag: gun50_1c0cbba46370c
X-Filterd-Recvd-Size: 8472
Received: from mail-qt1-f193.google.com (mail-qt1-f193.google.com [209.85.160.193])
	by imf19.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 16:56:32 +0000 (UTC)
Received: by mail-qt1-f193.google.com with SMTP id 44so3002737qtg.11
        for <linux-mm@kvack.org>; Thu, 15 Aug 2019 09:56:32 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=8Q3BUPafjT//7zqZyDAGCCoPTiMdeG8OI4h/hxD+trk=;
        b=l/2uXRd4T7HQOUDBG/JM+iUspGtfzLrxEqhgp3H9MuxzleYOE7XUTyFzkXSdKaCTcb
         q9MfXp3hYV+sssTkJDkOOSAm8bJQBLEjDvpI3VvG5Bah4pKJ0GwqOvPqD1hTMQ2juM4F
         wG3FcmtRNOq7XeZkSWigoJioXNZBC8G26nVgROu929tLZSwPk789miZ0cuWwTTyj8PQY
         kGTmipP1NMr8zg4r5RP6wvNh8HqOFhJI316r2CopVOgXT2m8TBtFcD5juD/oONpbcfrC
         7ZtrySmSL1jVyB5LFHnhVSicKT/IZ1SgzrKNZaX2H1Okq65iudeI58fGM7w480kbI10U
         mk4w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=8Q3BUPafjT//7zqZyDAGCCoPTiMdeG8OI4h/hxD+trk=;
        b=K+rbh0fgTIPjzE1TwAQ97tH5OZUQVhIfky7vSDVtXCF4DN7MipHe6YoDbdIeh7WHg9
         7ppkaGoOZRlq8wH85tzpHIvHnK9oQrkweimMZyv3TX6Gh0ibu+JH9FUbfUqxjpg7H807
         XIGDHMQ73psLmtTTiHed8w0020VqH36xOc4XwFReqlElzvA7Sq+W+z4MEenhwD0DDeLP
         +UcP/Tukb8y7Fcr3RzTFJzLAzx9YYNNCqG77s0xoblTh4cfjLoANlyWJ2iLGi23ZmSFx
         8TWjBKQ3eeO5JpDfdCABT86xPT/gJBHW5QPTAVGiTWTAF/bnolaP4btWYfnuz4SjWHLM
         +rIg==
X-Gm-Message-State: APjAAAVGJX+ErNMhhRf9LJIVi6m1zeVlXiDhEzJopgY78Iq7a0vOhZ7B
	zFDgU0HnpWsyPZrh+dac5P302Oyel1I=
X-Google-Smtp-Source: APXvYqzn3Iu7ObjjA8SMNGcPxln0Wb7FQwoIxDnrko+LZW/8NghOd8XtvpT4mfbuJe+bGykaqWSrJw==
X-Received: by 2002:ac8:4247:: with SMTP id r7mr4846720qtm.219.1565888192037;
        Thu, 15 Aug 2019 09:56:32 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id f133sm1620929qke.62.2019.08.15.09.56.31
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 15 Aug 2019 09:56:31 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hyJ39-0006Zn-5c; Thu, 15 Aug 2019 13:56:31 -0300
Date: Thu, 15 Aug 2019 13:56:31 -0300
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
Message-ID: <20190815165631.GK21596@ziepe.ca>
References: <20190814202027.18735-1-daniel.vetter@ffwll.ch>
 <20190814202027.18735-3-daniel.vetter@ffwll.ch>
 <20190814235805.GB11200@ziepe.ca>
 <20190815065829.GA7444@phenom.ffwll.local>
 <20190815122344.GA21596@ziepe.ca>
 <20190815132127.GI9477@dhcp22.suse.cz>
 <20190815141219.GF21596@ziepe.ca>
 <20190815155950.GN9477@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190815155950.GN9477@dhcp22.suse.cz>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 15, 2019 at 06:00:41PM +0200, Michal Hocko wrote:

> > AFAIK 'GFP_NOWAIT' is characterized by the lack of __GFP_FS and
> > __GFP_DIRECT_RECLAIM..
> >
> > This matches the existing test in __need_fs_reclaim() - so if you are
> > OK with GFP_NOFS, aka __GFP_IO which triggers try_to_compact_pages(),
> > allocations during OOM, then I think fs_reclaim already matches what
> > you described?
> 
> No GFP_NOFS is equally bad. Please read my other email explaining what
> the oom_reaper actually requires. In short no blocking on direct or
> indirect dependecy on memory allocation that might sleep.

It is much easier to follow with some hints on code, so the true
requirement is that the OOM repear not block on GFP_FS and GFP_IO
allocations, great, that constraint is now clear.

> If you can express that in the existing lockdep machinery. All
> fine. But then consider deployments where lockdep is no-no because
> of the overhead.

This is all for driver debugging. The point of lockdep is to find all
these paths without have to hit them as actual races, using debug
kernels.

I don't think we need this kind of debugging on production kernels?

> > The best we got was drivers tested the VA range and returned success
> > if they had no interest. Which is a big win to be sure, but it looks
> > like getting any more is not really posssible.
> 
> And that is already a great win! Because many notifiers only do care
> about particular mappings. Please note that backing off unconditioanlly
> will simply cause that the oom reaper will have to back off not doing
> any tear down anything.

Well, I'm working to propose that we do the VA range test under core
mmu notifier code that cannot block and then we simply remove the idea
of blockable from drivers using this new 'range notifier'. 

I think this pretty much solves the concern?

> > However, we could (probably even should) make the drivers fs_reclaim
> > safe.
> > 
> > If that is enough to guarantee progress of OOM, then lets consider
> > something like using current_gfp_context() to force PF_MEMALLOC_NOFS
> > allocation behavior on the driver callback and lockdep to try and keep
> > pushing on the the debugging, and dropping !blocking.
> 
> How are you going to enforce indirect dependency? E.g. a lock that is
> also used in other context which depend on sleepable memory allocation
> to move forward.

You mean like this:

       CPU0                                 CPU1
                                        mutex_lock()
                                        kmalloc(GFP_KERNEL)
                                        mutex_unlock()
  fs_reclaim_acquire()
  mutex_lock() <- illegal: lock dep assertion

?

lockdep handles this - that is what it does, it builds a graph of all
lock dependencies and requires the graph to be acyclic. So mutex_lock
depends on fs_reclaim_lock on CPU1 while on CPU0, fs_reclaim_lock
depends on mutex_lock. This is an ABBA locking cycle and lockdep will
reliably trigger.

So, if we wanted to do this, I'd probably suggest we retool
fs_reclaim's interface be more like

  prevent_gfp_flags(__GFP_IO | __GFP_FS);
  [..]
  restore_gfp_flags(__GFP_IO | __GFP_FS);

Which is lockdep based and follows the indirect lock dependencies you
talked about.

Then OOM and reclaim can specify the different flags they want
blocked.  We could probably use the same API with WQ_MEM_RECLAIM as I
was chatting with Tejun about:

https://www.spinics.net/lists/linux-rdma/msg77362.html

IMHO this stuff is *super complicated* for those of us outside the mm
subsystem, so having some really clear annotations like the above
would go a long way to help understand these special constraints.

I'm pretty sure there are lots of driver bugs related to using the
wrong GFP flags in the kernel.

> Really, this was aimed to give a very simple debugging aid. If it is
> considered to be so controversial, even though I really do not see why,
> then let's just drop it on the floor.

My concern is that the requirement was very unclear. I'm trying to
understand all the bits of how these notifiers work and the exact
semantic of this OOM path have been vauge if it is really some GFP
flag restriction or truely related to not sleeping.

Jason

