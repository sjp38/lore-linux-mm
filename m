Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 14BAF440846
	for <linux-mm@kvack.org>; Thu, 24 Aug 2017 08:38:12 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id g10so2937976pgc.2
        for <linux-mm@kvack.org>; Thu, 24 Aug 2017 05:38:12 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id o128si2746962pfo.226.2017.08.24.05.38.10
        for <linux-mm@kvack.org>;
        Thu, 24 Aug 2017 05:38:11 -0700 (PDT)
Date: Thu, 24 Aug 2017 13:36:48 +0100
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: Intermittent memory corruption with v4.13-rc6+ and earlier
Message-ID: <20170824123647.GA19698@leverpostej>
References: <20170824113743.GA14737@leverpostej>
 <20170824114833.GH5943@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170824114833.GH5943@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-kernel@vger.kernel.org, syzkaller@googlegroups.com, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Vlastimil Babka <vbabka@suse.cz>, will.deacon@arm.com

On Thu, Aug 24, 2017 at 01:48:34PM +0200, Michal Hocko wrote:
> On Thu 24-08-17 12:37:43, Mark Rutland wrote:
> > Hi,
> > 
> > I'm chasing intermittent memory corruption bugs seen at least on rc5,
> > rc6, and yesterday's HEAD (98b9f8a4549909c6), on arm64. 
> > 
> > It looks like we make use of dangling references to a freed struct file,
> > which is caught by KASAN. Without KASAN, I see a number of other
> > intermittent issues that I suspect are the result of this memory
> > corruption. I've included an example splat below, complete with KASAN's
> > alloc/free traces at the end of this mail.
> 
> Is it possible this is the same issue as the one fixed by
> http://lkml.kernel.org/r/20170823211408.31198-1-ebiggers3@gmail.com?

That sounds plausible, and so far the fix seems to help. Thanks for the
pointer!

I'll leave that running for a while, just in case.

Thanks,
Mark.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
