Return-Path: <SRS0=30+Z=WL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS,USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E2178C3A589
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 12:23:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9147C2083B
	for <linux-mm@archiver.kernel.org>; Thu, 15 Aug 2019 12:23:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=ziepe.ca header.i=@ziepe.ca header.b="QRZRxa6u"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9147C2083B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ziepe.ca
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 297BD6B0273; Thu, 15 Aug 2019 08:23:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2488F6B0274; Thu, 15 Aug 2019 08:23:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 110DD6B0275; Thu, 15 Aug 2019 08:23:47 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0061.hostedemail.com [216.40.44.61])
	by kanga.kvack.org (Postfix) with ESMTP id E362A6B0273
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 08:23:46 -0400 (EDT)
Received: from smtpin16.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 857912C2A
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 12:23:46 +0000 (UTC)
X-FDA: 75824578452.16.bag37_78332a3165050
X-HE-Tag: bag37_78332a3165050
X-Filterd-Recvd-Size: 6811
Received: from mail-qk1-f195.google.com (mail-qk1-f195.google.com [209.85.222.195])
	by imf15.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Thu, 15 Aug 2019 12:23:45 +0000 (UTC)
Received: by mail-qk1-f195.google.com with SMTP id w18so928019qki.0
        for <linux-mm@kvack.org>; Thu, 15 Aug 2019 05:23:45 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=ziepe.ca; s=google;
        h=date:from:to:subject:message-id:references:mime-version
         :content-disposition:in-reply-to:user-agent;
        bh=h/NjbiF58YEr9Revz70cBCU6NfRlKsj4YDdyw6gTZ8c=;
        b=QRZRxa6uW2hXnZ8eTQQopuiBP271xdX+fOVcfPMGphMyj4qkZvTA3bvr3NVcTUgJ4b
         g7cYi9DXfd0nx1PJiB9zbyYexUEnL/TyKFcnqlU9itbQYJHcBk+NvXCIHLr5vydDsaW9
         HxtfvgAhk6C9z6XxJVL8DA/IHRUSIdqgv2XFb6qgKqy9wN5SaMKB+tWodxYHj2Tazxb5
         wr/TBDbDuNuNTvUV0pyE8dW8Yn8CfWpaCEwqP98qN2Bz0do/zjPBG+R1JBOrTPi0uVf2
         Bhi3rzbQ6C2OZrhz/8Bcnwq3iay/pTHkFiKuorlhvYkpuVxUaUla+QeaeraKcsqaURqL
         xCIg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:date:from:to:subject:message-id:references
         :mime-version:content-disposition:in-reply-to:user-agent;
        bh=h/NjbiF58YEr9Revz70cBCU6NfRlKsj4YDdyw6gTZ8c=;
        b=YUHDUe2g6sgqg0fxnKOc8igI25tHkJEvrHI0aXe7IoU3VV49z2LK7Lqd+wHUZReGXd
         /qVQQSwO6owobdIt5AqXKlVRpcjPmz/AwPt+veKxpdSpsRijMv2xqU/g/r1tpcV4eWUf
         Uk7G1yhuIOI/gZHTUsgS1KREgeqEfygWXTHjjq8DAnx5HwzT3G+MAuuqkagla0mhkrXv
         t61KiuGa0lXQemtKw/0bDdtXy6uysSBG0Fr22XBo3MIMbBnByyuaQEvjO2FgWy/YmtXF
         bQUrRUfwqkRBds5gl1fr4usDdWIwNquw7IZDjZmP7KDASm1fOc93qQrehbdjQnMj6b/u
         XdNw==
X-Gm-Message-State: APjAAAXW32W/U9WHbXidlmtWVjaX35qQbiH80FMOF+5RbTQtKg/kclC8
	MO72dUSmi+Hyomc3PwV3suLy6w==
X-Google-Smtp-Source: APXvYqxCyiP6QSE5R+6YFBEjPHkw2WqRgEuobxPJuNaULXaRzrprJ2WNqFxX5NyrcJoKKaFuoawKgg==
X-Received: by 2002:a37:6646:: with SMTP id a67mr3849693qkc.216.1565871825180;
        Thu, 15 Aug 2019 05:23:45 -0700 (PDT)
Received: from ziepe.ca (hlfxns017vw-156-34-55-100.dhcp-dynamic.fibreop.ns.bellaliant.net. [156.34.55.100])
        by smtp.gmail.com with ESMTPSA id y26sm1796517qta.39.2019.08.15.05.23.44
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 15 Aug 2019 05:23:44 -0700 (PDT)
Received: from jgg by mlx.ziepe.ca with local (Exim 4.90_1)
	(envelope-from <jgg@ziepe.ca>)
	id 1hyEnA-0005js-3K; Thu, 15 Aug 2019 09:23:44 -0300
Date: Thu, 15 Aug 2019 09:23:44 -0300
From: Jason Gunthorpe <jgg@ziepe.ca>
To: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org,
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
Message-ID: <20190815122344.GA21596@ziepe.ca>
References: <20190814202027.18735-1-daniel.vetter@ffwll.ch>
 <20190814202027.18735-3-daniel.vetter@ffwll.ch>
 <20190814235805.GB11200@ziepe.ca>
 <20190815065829.GA7444@phenom.ffwll.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190815065829.GA7444@phenom.ffwll.local>
User-Agent: Mutt/1.9.4 (2018-02-28)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Aug 15, 2019 at 08:58:29AM +0200, Daniel Vetter wrote:
> On Wed, Aug 14, 2019 at 08:58:05PM -0300, Jason Gunthorpe wrote:
> > On Wed, Aug 14, 2019 at 10:20:24PM +0200, Daniel Vetter wrote:
> > > In some special cases we must not block, but there's not a
> > > spinlock, preempt-off, irqs-off or similar critical section already
> > > that arms the might_sleep() debug checks. Add a non_block_start/end()
> > > pair to annotate these.
> > > 
> > > This will be used in the oom paths of mmu-notifiers, where blocking is
> > > not allowed to make sure there's forward progress. Quoting Michal:
> > > 
> > > "The notifier is called from quite a restricted context - oom_reaper -
> > > which shouldn't depend on any locks or sleepable conditionals. The code
> > > should be swift as well but we mostly do care about it to make a forward
> > > progress. Checking for sleepable context is the best thing we could come
> > > up with that would describe these demands at least partially."
> > 
> > But this describes fs_reclaim_acquire() - is there some reason we are
> > conflating fs_reclaim with non-sleeping?
> 
> No idea why you tie this into fs_reclaim. We can definitly sleep in there,
> and for e.g. kswapd (which also wraps everything in fs_reclaim) we're
> event supposed to I thought. To make sure we can get at the last bit of
> memory by flushing all the queues and waiting for everything to be cleaned
> out.

AFAIK the point of fs_reclaim is to prevent "indirect dependency upon
the page allocator" ie a justification that was given this !blockable
stuff.

For instance:

  fs_reclaim_acquire()
  kmalloc(GFP_KERNEL) <- lock dep assertion

And further, Michal's concern about indirectness through locks is also
handled by lockdep:

       CPU0                                 CPU1
                                        mutex_lock()
                                        kmalloc(GFP_KERNEL)
                                        mutex_unlock()
  fs_reclaim_acquire()
  mutex_lock() <- lock dep assertion

In other words, to prevent recursion into the page allocator you use
fs_reclaim_acquire(), and lockdep verfies it in its usual robust way.

I asked Tejun about this once in regards to WQ_MEM_RECLAIM and he
explained that it means you can't call the allocator functions in a
way that would recurse into reclaim (ie instead use instead GFP_ATOMIC, or
tolerate allocation failure, or various other things).

So, the reason I bring it up is half the justifications you posted for
blockable had to do with not recursing into reclaim and deadlocking,
and didn't seem to have much to do with blocking.

I'm asking if *non-blocking* is really the requirement or if this is
just the usual 'do not deadlock on the allocator' thing reclaim paths
alread have?

Jason

