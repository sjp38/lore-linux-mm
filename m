Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id EF1476B0038
	for <linux-mm@kvack.org>; Tue, 17 Mar 2015 21:53:58 -0400 (EDT)
Received: by pdbcz9 with SMTP id cz9so26890185pdb.3
        for <linux-mm@kvack.org>; Tue, 17 Mar 2015 18:53:58 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id y5si32782614pdn.35.2015.03.17.18.53.57
        for <linux-mm@kvack.org>;
        Tue, 17 Mar 2015 18:53:58 -0700 (PDT)
Message-ID: <1426643634.5570.14.camel@intel.com>
Subject: Re: [LKP] [mm] cc87317726f: WARNING: CPU: 0 PID: 1 at
 drivers/iommu/io-pgtable-arm.c:413 __arm_lpae_unmap+0x341/0x380()
From: Huang Ying <ying.huang@intel.com>
Date: Wed, 18 Mar 2015 09:53:54 +0800
In-Reply-To: <20150317192413.GA7772@phnom.home.cmpxchg.org>
References: <1426227621.6711.238.camel@intel.com>
	 <CA+55aFxWTg_kCxGChLJGU=DFg0K_q842bkziktXu6B2fX=mXYQ@mail.gmail.com>
	 <20150317192413.GA7772@phnom.home.cmpxchg.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, LKML <linux-kernel@vger.kernel.org>, LKP ML <lkp@01.org>, linux-mm <linux-mm@kvack.org>

On Tue, 2015-03-17 at 15:24 -0400, Johannes Weiner wrote:
> On Tue, Mar 17, 2015 at 10:15:29AM -0700, Linus Torvalds wrote:
> > Explicitly adding the emails of other people involved with that commit
> > and the original oom thread to make sure people are aware, since this
> > didn't get any response.
> > 
> > Commit cc87317726f8 fixed some behavior, but also seems to have turned
> > an oom situation into a complete hang. So presumably we shouldn't loop
> > *forever*. Hmm?
> 
> It seems we are between a rock and a hard place here, as we reverted
> specifically to that endless looping on request of filesystem people.
> They said[1] they rely on these allocations never returning NULL, or
> they might fail inside a transactions and corrupt on-disk data.
> 
> Huang, against which kernels did you first run this test on this exact
> setup?  Is there a chance you could try to run a kernel without/before
> 9879de7373fc?  I want to make sure I'm not missing something, but all
> versions preceding this commit should also have the same hang.  There
> should only be a tiny window between 9879de7373fc and cc87317726f8 --
> v3.19 -- where these allocations are allowed to fail.

I checked the test result of v3.19-rc6.  It shows that boot will hang at
the same position.

BTW: the test is run on 32 bit system.

Best Regards,
Huang, Ying


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
