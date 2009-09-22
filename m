Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 37BA66B005C
	for <linux-mm@kvack.org>; Tue, 22 Sep 2009 19:35:36 -0400 (EDT)
Received: by bwz24 with SMTP id 24so183587bwz.38
        for <linux-mm@kvack.org>; Tue, 22 Sep 2009 16:35:36 -0700 (PDT)
Date: Wed, 23 Sep 2009 01:35:31 +0200
From: Karol Lewandowski <karol.k.lewandowski@gmail.com>
Subject: Re: [BUG 2.6.30+] e100 sometimes causes oops during resume
Message-ID: <20090922233531.GA3198@bizet.domek.prywatny>
References: <20090915120538.GA26806@bizet.domek.prywatny> <200909170118.53965.rjw@sisk.pl> <4AB29F4A.3030102@intel.com> <200909180027.37387.rjw@sisk.pl>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200909180027.37387.rjw@sisk.pl>
Sender: owner-linux-mm@kvack.org
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: david.graham@intel.com, Karol Lewandowski <karol.k.lewandowski@gmail.com>, "e1000-devel@lists.sourceforge.net" <e1000-devel@lists.sourceforge.net>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, Sep 18, 2009 at 12:27:37AM +0200, Rafael J. Wysocki wrote:
> On Thursday 17 September 2009, Graham, David wrote:
> > Rafael J. Wysocki wrote:
> > > I guess the driver releases its DMA buffer during suspend and attempts to
> > > allocate it back on resume, which is not really smart (if that really is the
> > > case).

> > Yes, we free a 70KB block (0x80 by 0x230 bytes) on suspend and 
> > reallocate on resume, and so that's an Order 5 request. It looks 
> > symmetric, and hasn't changed for years. I don't think we are leaking 
> > memory, which points back to that the memory is too fragmented to 
> > satisfy the request.
> > 
> > I also concur that Rafael's commit 6905b1f1 shouldn't change the logic 
> > in the driver for systems with e100 (like yours Karol) that could 
> > already sleep, and I don't see anything else in the driver that looks to 
> > be relevant. I'm expecting that your test result without commit 6905b1f1 
> > will still show the problem.
> > 
> > So I wonder if this new issue may be triggered by some other change in 
> > the memory subsystem ?

> I think so.  There have been reports about order 2 allocations failing for
> 2.6.31, so it looks like newer kernels are more likely to expose such problems.
> 
> Adding linux-mm to the CC list.

I've hit this bug 2 times since my last email.  Is there anything I
could do?

Maybe I should revert following commits (chosen somewhat randomly)?

1. 49255c619fbd482d704289b5eb2795f8e3b7ff2e

2. dd5d241ea955006122d76af88af87de73fec25b4 - alters changes made by
commit above

Any ideas?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
