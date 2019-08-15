Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E2138C3A59C
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 17:17:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 99188205F4
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 17:17:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="lrLcqqVV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 99188205F4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3DF456B0005; Thu, 15 Aug 2019 13:17:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3901B6B0295; Thu, 15 Aug 2019 13:17:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 27F2B6B02AB; Thu, 15 Aug 2019 13:17:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0249.hostedemail.com [216.40.44.249])
	by kanga.kvack.org (Postfix) with ESMTP id 057046B0005
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 13:17:51 -0400 (EDT)
Received: from smtpin05.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id A10A66C33
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 17:17:51 +0000 (UTC)
X-FDA: 75825319542.05.neck01_4491db00c1c0a
X-HE-Tag: neck01_4491db00c1c0a
X-Filterd-Recvd-Size: 6869
Received: from mail-qt1-f195.google.com (mail-qt1-f195.google.com [209.85.160.195])
	by imf09.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 17:17:51 +0000 (UTC)
Received: by mail-qt1-f195.google.com with SMTP id e8so3094784qtp.7
        for <linux-mm@kvack.org>; Thu, 15 Aug 2019 10:17:50 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=z8ffACx97UoCYoWbcK20vb+vJc46Di7ZY3J/Q+sVrN4=;
        b=lrLcqqVVbBaaW5DmpJaOL2mAta1VuHGEWegYy4v8k9O/KYbA6trUfUtSwOXUA310uN
         zuvisW/tOnzl/qIbzDfd4s3DNn2oJk4o0dxwnY/ZA56xooLiBHwRGX7/e/IRF4uCvJRB
         gB253hM+6t/Z3jYXj3AHAc09XhS2/PZIrdxHVerl0xsJ/so5ncLIXCUE4xzYVLJEjsPP
         GkcGuLjNzYWjfCaXPfSyoxq6CfnLddPdNdVqoeGSnNtvn/yy7fnMHG5zCWqXToBvxETG
         SAyXDrs7d4csk5SF9eMf58/iCQdcp2DH2M7Cmh4WFK4tJIJ45uHTq8hpFiNJmrDGh4h8
         A8YQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=z8ffACx97UoCYoWbcK20vb+vJc46Di7ZY3J/Q+sVrN4=;
        b=L9DRIwZJ57U17oIXdw8mQpMcXevBPWn1+0RIFIrK3p+NXzomFy2GqbXvhJOWfB6Ud0
         dPXnMXTVWC68mYaQe34b6JhK/KAzR5tfxw0FRee5DV1AsZY2IQhoo8L4EtkQhMQajObU
         7g1KbtlZTSnnUWwqkjiR6TLuGetDxV7JbL27M7WsPLv+sH+P6i34c2EEm3ByrZnoVAtE
         es5UWygGHAnthn8B1UIzEmHmPUfNlkOK7AkFjxabFMScgQVzemCVJYhblXREujClz136
         /e7kOHBRmkd7B6JvWiUPvMfCueT4UD5OED/0ECkqHXTrKRiYtJ+6WbrOVJh4AOapV7Mg
         JvoQ==
X-Gm-Message-State: APjAAAXtzRNBpLxKUCJfqdQmxz6mQ7cbTScmGlNWBouhhRKMpYvyVvXc
	FEp9WVgPDBxkj4Z9YimGgPD4HA==
X-Google-Smtp-Source: APXvYqy8bClE2PtYhlNsbzNy3sfuIfpzHgK8LEd061uqbj3o3CPG3Uelsdo/F1E4oVxX/Cn3DR0XDA==
X-Received: by 2002:ac8:6b45:: with SMTP id x5mr4726244qts.329.1565889470494;
        Thu, 15 Aug 2019 10:17:50 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id x28sm1853523qtk.8.2019.08.15.10.17.50
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 15 Aug 2019 10:17:50 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hyJNl-0006n3-Lb; Thu, 15 Aug 2019 14:17:49 -0300
Date: Thu, 15 Aug 2019 14:17:49 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>, LKML <linux-kernel@vger.kernel.org>,
	linux-mm@kvack.org,
	DRI Development <dri-devel@lists.freedesktop.org>,
	Intel Graphics Development <intel-gfx@lists.freedesktop.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Rientjes <rientjes@google.com>,
	Christian =?utf-8?B?S8O2bmln?= <christian.koenig@amd.com>,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	Wei Wang <wvw@google.com>,
	Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
	Thomas Gleixner <tglx@linutronix.de>, Jann Horn <jannh@google.com>,
	Feng Tang <feng.tang@intel.com>, Kees Cook <keescook@chromium.org>,
	Randy Dunlap <rdunlap@infradead.org>,
	Daniel Vetter <daniel.vetter@intel.com>
Subject: Re: [PATCH 2/5] kernel.h: Add non_block_start/end()
Message-ID: <20190815171749.GM21596@ziepe.ca>
References: <20190814202027.18735-1-daniel.vetter@ffwll.ch>
 <20190814202027.18735-3-daniel.vetter@ffwll.ch>
 <20190814235805.GB11200@ziepe.ca>
 <20190815065829.GA7444@phenom.ffwll.local>
 <20190815122344.GA21596@ziepe.ca>
 <20190815132127.GI9477@dhcp22.suse.cz>
 <20190815141219.GF21596@ziepe.ca>
 <20190815155950.GN9477@dhcp22.suse.cz>
 <20190815165631.GK21596@ziepe.ca>
 <20190815171156.GB30916@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190815171156.GB30916@redhat.com>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 15, 2019 at 01:11:56PM -0400, Jerome Glisse wrote:
> On Thu, Aug 15, 2019 at 01:56:31PM -0300, Jason Gunthorpe wrote:
> > On Thu, Aug 15, 2019 at 06:00:41PM +0200, Michal Hocko wrote:
> > 
> > > > AFAIK 'GFP_NOWAIT' is characterized by the lack of __GFP_FS and
> > > > __GFP_DIRECT_RECLAIM..
> > > >
> > > > This matches the existing test in __need_fs_reclaim() - so if you are
> > > > OK with GFP_NOFS, aka __GFP_IO which triggers try_to_compact_pages(),
> > > > allocations during OOM, then I think fs_reclaim already matches what
> > > > you described?
> > > 
> > > No GFP_NOFS is equally bad. Please read my other email explaining what
> > > the oom_reaper actually requires. In short no blocking on direct or
> > > indirect dependecy on memory allocation that might sleep.
> > 
> > It is much easier to follow with some hints on code, so the true
> > requirement is that the OOM repear not block on GFP_FS and GFP_IO
> > allocations, great, that constraint is now clear.
> > 
> > > If you can express that in the existing lockdep machinery. All
> > > fine. But then consider deployments where lockdep is no-no because
> > > of the overhead.
> > 
> > This is all for driver debugging. The point of lockdep is to find all
> > these paths without have to hit them as actual races, using debug
> > kernels.
> > 
> > I don't think we need this kind of debugging on production kernels?
> > 
> > > > The best we got was drivers tested the VA range and returned success
> > > > if they had no interest. Which is a big win to be sure, but it looks
> > > > like getting any more is not really posssible.
> > > 
> > > And that is already a great win! Because many notifiers only do care
> > > about particular mappings. Please note that backing off unconditioanlly
> > > will simply cause that the oom reaper will have to back off not doing
> > > any tear down anything.
> > 
> > Well, I'm working to propose that we do the VA range test under core
> > mmu notifier code that cannot block and then we simply remove the idea
> > of blockable from drivers using this new 'range notifier'. 
> > 
> > I think this pretty much solves the concern?
> 
> I am not sure i follow what you propose here ? Like i pointed out in
> another email for GPU we do need to be able to sleep (we might get
> lucky and not need too but this is runtime thing) within notifier
> range_start callback. This has been something allow by notifier since
> it has been introduced in the kernel.

Sorry, I mean remove the idea of the blockable flag from the
drivers. Drivers will always be able to block, within the existing
limitation of fs_reclaim

Jason

