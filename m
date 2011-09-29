Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 267799000BD
	for <linux-mm@kvack.org>; Thu, 29 Sep 2011 15:07:48 -0400 (EDT)
Received: by gya6 with SMTP id 6so1104934gya.14
        for <linux-mm@kvack.org>; Thu, 29 Sep 2011 12:07:46 -0700 (PDT)
Date: Thu, 29 Sep 2011 12:07:41 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: Question about memory leak detector giving false positive report
 for net/core/flow.c
Message-ID: <20110929190741.GA10425@mtj.dyndns.org>
References: <CA+v9cxadZzWr35Q9RFzVgk_NZsbZ8PkVLJNxjBAMpargW9Lm4Q@mail.gmail.com>
 <1317054774.6363.9.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <20110926165024.GA21617@e102109-lin.cambridge.arm.com>
 <1317066395.2796.11.camel@edumazet-laptop>
 <20110928172342.GH23559@e102109-lin.cambridge.arm.com>
 <alpine.DEB.2.00.1109290907450.9382@router.home>
 <20110929141809.GD32023@e102109-lin.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110929141809.GD32023@e102109-lin.cambridge.arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Christoph Lameter <cl@gentwo.org>, Eric Dumazet <eric.dumazet@gmail.com>, Huajun Li <huajun.li.lee@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, netdev <netdev@vger.kernel.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Thu, Sep 29, 2011 at 03:18:10PM +0100, Catalin Marinas wrote:
> On Thu, Sep 29, 2011 at 03:08:47PM +0100, Christoph Lameter wrote:
> > On Wed, 28 Sep 2011, Catalin Marinas wrote:
> > 
> > > I tried this but it's tricky. The problem is that the percpu pointer
> > > returned by alloc_percpu() does not directly point to the per-cpu chunks
> > > and kmemleak would report most percpu allocations as leaks. So far the
> > > workaround is to simply mark the alloc_percpu() objects as never leaking
> > > and at least we avoid false positives in other areas. See the patch
> > > below (note that you have to increase the CONFIG_KMEMLEAK_EARLY_LOG_SIZE
> > > as there are many alloc_percpu() calls before kmemleak is fully
> > > initialised):
> > 
> > Seems that kernel.org is out and so tejon wont be seeing these.
> 
> That's ok, I don't aim this at the upcoming merging window. I don't have
> an alternative email address for him.

That's htejun@gmail.com but as long as lkml is cc'd I can read the
emails.  Lack of replies is more due to the month long vacation which
just ended. ;)

Thank you.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
