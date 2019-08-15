Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 62EE4C3A589
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 18:24:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0ABBD2086C
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 18:24:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="UwFqsKZi"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0ABBD2086C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7CAED6B0285; Thu, 15 Aug 2019 14:24:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 755316B0287; Thu, 15 Aug 2019 14:24:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 61B766B0295; Thu, 15 Aug 2019 14:24:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0245.hostedemail.com [216.40.44.245])
	by kanga.kvack.org (Postfix) with ESMTP id 397966B0285
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 14:24:51 -0400 (EDT)
Received: from smtpin19.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id D44AC180AD805
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 18:24:50 +0000 (UTC)
X-FDA: 75825488340.19.rule97_475d2cacc0557
X-HE-Tag: rule97_475d2cacc0557
X-Filterd-Recvd-Size: 6483
Received: from mail-qk1-f196.google.com (mail-qk1-f196.google.com [209.85.222.196])
	by imf46.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 18:24:50 +0000 (UTC)
Received: by mail-qk1-f196.google.com with SMTP id p13so2549346qkg.13
        for <linux-mm@kvack.org>; Thu, 15 Aug 2019 11:24:50 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=G4JHudwK1l0Pa0YXZDZdUoarWmEaiz0kaB3NPKkUFrY=;
        b=UwFqsKZiJqRFsggeYnYEJQ5ti/D+4zJ6BdWzCQ9+5ZVyFzNT0pZp3Z47GysMlVkWVa
         s6il5o0C2XSsvu08linHUpE1UuKtws+6kl5bvb6N8JTjKYNm+ZFsMF/aS7KIuwXwY5PL
         ifLaV1KikbFHjyWGyYq9j2pnPvRA3ulCCU5LBrDPRPTf00Ev8+G4r7ZG1fWssXt+dt8m
         fSIEjUyPUUjE4Cyc7v3Mk2yhOmcAHNWHAjyBbiBB5PDt75HzpgPI6NlB4kYJlFCHPv45
         rERv+1byueCget/MOMNWxs6jcSzjmerqYaJGXU5V9yIGrPZkmI1GoIgdy70yvzXm/v2/
         F53g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:cc:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=G4JHudwK1l0Pa0YXZDZdUoarWmEaiz0kaB3NPKkUFrY=;
        b=qgnGfUYHslbQO+B5rco3xPh2V+czDoz1auj1hjRCGFs/On7yKUJEZ3hXY2rrjQfRaH
         GkDSgiU1hwllWjWQ/VZDShCmSgwY9BH7/e7u/kmmP5ny6y3isRL7t8XWLCVYLARBWSJi
         JJX1ELgSO+sxP4mMAwTZ9peV+5f45HpLSXN1vIV5IZw6BmSUFmXJEKktuj3e4DhTq7NQ
         XHL8cgIOaeo5vnzHGt2xxasncdvfqlVm6xCpaNmLfAIfsJGOAv+IjUZORa0HBVSy1QyT
         vBN6p01K1l3v7k/lXh8u65UmOsyF6dMK7ESeyjCBBYLlRrA3XziB4ljOuw4C0xo1/wff
         3P+A==
X-Gm-Message-State: APjAAAVKXd/2XHV/XK7HQpD2eNS5fNgar0qwMdfBNUu1i6n/WVHhRLBz
	tqOiU74PN9dxrTkz3mNgE6MwsQ==
X-Google-Smtp-Source: APXvYqznGQA2Mb3OUz3S4NsNelaEmfdP1JHskBC7RLkLXGfv6FD94/o+7zgymYT+l5Mz5o8/J+Om7Q==
X-Received: by 2002:a37:ef1a:: with SMTP id j26mr5561517qkk.474.1565893489768;
        Thu, 15 Aug 2019 11:24:49 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id g3sm1745991qke.105.2019.08.15.11.24.48
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 15 Aug 2019 11:24:48 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hyKQa-0007R9-AO; Thu, 15 Aug 2019 15:24:48 -0300
Date: Thu, 15 Aug 2019 15:24:48 -0300
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
Message-ID: <20190815182448.GP21596@ziepe.ca>
References: <20190814202027.18735-1-daniel.vetter@ffwll.ch>
 <20190814202027.18735-3-daniel.vetter@ffwll.ch>
 <20190814235805.GB11200@ziepe.ca>
 <20190815065829.GA7444@phenom.ffwll.local>
 <20190815122344.GA21596@ziepe.ca>
 <20190815132127.GI9477@dhcp22.suse.cz>
 <20190815141219.GF21596@ziepe.ca>
 <20190815155950.GN9477@dhcp22.suse.cz>
 <20190815165631.GK21596@ziepe.ca>
 <20190815174207.GR9477@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190815174207.GR9477@dhcp22.suse.cz>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 15, 2019 at 07:42:07PM +0200, Michal Hocko wrote:
> On Thu 15-08-19 13:56:31, Jason Gunthorpe wrote:
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
> 
> I still do not get why do you put FS/IO into the picture. This is really
> about __GFP_DIRECT_RECLAIM.

Like I said this is complicated, translating "no blocking on direct or
indirect dependecy on memory allocation that might sleep" into GFP
flags is hard for us outside the mm community.

So the contraint here is no __GFP_DIRECT_RECLAIM?

I bring up FS/IO because that is what Tejun mentioned when I asked him
about reclaim restrictions, and is what fs_reclaim_acquire() is
already sensitive too. It is pretty confusing if we have places using
the word 'reclaim' with different restrictions. :(

> >        CPU0                                 CPU1
> >                                         mutex_lock()
> >                                         kmalloc(GFP_KERNEL)
> 
> no I mean __GFP_DIRECT_RECLAIM here.
> 
> >                                         mutex_unlock()
> >   fs_reclaim_acquire()
> >   mutex_lock() <- illegal: lock dep assertion
> 
> I cannot really comment on how that is achieveable by lockdep.

??? I am trying to explain this is already done and working today. The
above example will already fault with lockdep enabled.

This is existing debugging we can use and improve upon rather that
invent new debugging.

Jason

