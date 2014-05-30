Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id C51366B0035
	for <linux-mm@kvack.org>; Thu, 29 May 2014 20:21:27 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id bj1so731925pad.39
        for <linux-mm@kvack.org>; Thu, 29 May 2014 17:21:27 -0700 (PDT)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [2001:44b8:8060:ff02:300:1:6:6])
        by mx.google.com with ESMTP id ty7si3136729pab.10.2014.05.29.17.21.26
        for <linux-mm@kvack.org>;
        Thu, 29 May 2014 17:21:26 -0700 (PDT)
Date: Fri, 30 May 2014 10:21:13 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [RFC 2/2] x86_64: expand kernel stack to 16K
Message-ID: <20140530002113.GC14410@dastard>
References: <1401260039-18189-2-git-send-email-minchan@kernel.org>
 <CA+55aFxXdc22dirnE49UbQP_2s2vLQpjQFL+NptuyK7Xry6c=g@mail.gmail.com>
 <20140528223142.GO8554@dastard>
 <CA+55aFyRk6_v6COPGVvu6hvt=i2A8-dPcs1X3Ydn1g24AxbPkg@mail.gmail.com>
 <20140529013007.GF6677@dastard>
 <CA+55aFzdq2V-Q3WUV7hQJG8jBSAvBqdYLVTNtbD4ObVZ5yDRmw@mail.gmail.com>
 <20140529072633.GH6677@dastard>
 <CA+55aFx+j4104ZFmA-YnDtyfmV4FuejwmGnD5shfY0WX4fN+Kg@mail.gmail.com>
 <20140529235308.GA14410@dastard>
 <20140530000649.GA3477@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140530000649.GA3477@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Jens Axboe <axboe@kernel.dk>, Minchan Kim <minchan@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Rusty Russell <rusty@rustcorp.com.au>, "Michael S. Tsirkin" <mst@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Steven Rostedt <rostedt@goodmis.org>

On Thu, May 29, 2014 at 08:06:49PM -0400, Dave Jones wrote:
> On Fri, May 30, 2014 at 09:53:08AM +1000, Dave Chinner wrote:
> 
>  > That sounds like a plan. Perhaps it would be useful to add a
>  > WARN_ON_ONCE(stack_usage > 8k) (or some other arbitrary depth beyond
>  > 8k) so that we get some indication that we're hitting a deep stack
>  > but the system otherwise keeps functioning. That gives us some
>  > motivation to keep stack usage down but isn't a fatal problem like
>  > it is now....
> 
> We have check_stack_usage() and DEBUG_STACK_USAGE for this.
> Though it needs some tweaking if we move to 16K

Right, but it doesn't throw loud warnings when a specific threshold
is reached - it just issues a quiet message when a process exits
telling you what the maximum was without giving us a stack to chew
on....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
