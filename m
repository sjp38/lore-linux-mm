Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 73A366B03BF
	for <linux-mm@kvack.org>; Tue, 11 Apr 2017 14:56:00 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id w204so590247wmd.16
        for <linux-mm@kvack.org>; Tue, 11 Apr 2017 11:56:00 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d25si27319335wrb.160.2017.04.11.11.55.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 11 Apr 2017 11:55:59 -0700 (PDT)
Date: Tue, 11 Apr 2017 20:55:56 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: Add additional consistency check
Message-ID: <20170411185555.GE21171@dhcp22.suse.cz>
References: <20170404201334.GV15132@dhcp22.suse.cz>
 <CAGXu5jL1t2ZZkwnGH9SkFyrKDeCugSu9UUzvHf3o_MgraDFL1Q@mail.gmail.com>
 <20170411134618.GN6729@dhcp22.suse.cz>
 <CAGXu5j+EVCU1WrjpMmr0PYW2N_RzF0tLUgFumDR+k4035uqthA@mail.gmail.com>
 <20170411141956.GP6729@dhcp22.suse.cz>
 <alpine.DEB.2.20.1704111110130.24725@east.gentwo.org>
 <20170411164134.GA21171@dhcp22.suse.cz>
 <alpine.DEB.2.20.1704111254390.25069@east.gentwo.org>
 <20170411183035.GD21171@dhcp22.suse.cz>
 <alpine.DEB.2.20.1704111335540.6544@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1704111335540.6544@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue 11-04-17 13:44:02, Cristopher Lameter wrote:
> On Tue, 11 Apr 2017, Michal Hocko wrote:
> 
> > > So we are already handling that condition. Why change things? Add a BUG_ON
> > > if you want to make SLAB consistent.
> >
> > I hate to repeat myself but let me do it for the last time in this
> > thread. BUG_ON for something that is recoverable is completely
> > inappropriate. And I consider kfree with a bogus pointer something that
> > we can easily recover from. There are other cases where the internal
> > state of the allocator is compromised to the point where continuing is
> > not possible and BUGing there is acceptable but kfree(garbage) is not
> > that case.
> 
> kfree(garbage) by the core kernel has so far been taken as a sign of
> severe memory corruption and the kernels have been oopsing when this
> occurred. This has been that way for a decade or so.

which doesn't make it a valid decision. We just overuse BUG*

> kfree() is used by
> the allocators and various other core kernel components. If the metadata
> of the core kernel is compromised then it is safest to stop right there.
> 
> If you want to change things then someone has to do some work. What you
> are saying is not the way things are implemented. Sorry.

I didn't say anything like that. Hence the proposed patch which still
needs some more thinking and evaluation.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
