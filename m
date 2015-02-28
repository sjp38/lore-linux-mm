Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f170.google.com (mail-yk0-f170.google.com [209.85.160.170])
	by kanga.kvack.org (Postfix) with ESMTP id EEAAE6B0080
	for <linux-mm@kvack.org>; Sat, 28 Feb 2015 11:42:06 -0500 (EST)
Received: by ykq19 with SMTP id 19so9858173ykq.9
        for <linux-mm@kvack.org>; Sat, 28 Feb 2015 08:42:06 -0800 (PST)
Received: from imap.thunk.org (imap.thunk.org. [2600:3c02::f03c:91ff:fe96:be03])
        by mx.google.com with ESMTPS id q84si3549011ykq.47.2015.02.28.08.42.04
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Sat, 28 Feb 2015 08:42:05 -0800 (PST)
Date: Sat, 28 Feb 2015 11:41:58 -0500
From: Theodore Ts'o <tytso@mit.edu>
Subject: Re: How to handle TIF_MEMDIE stalls?
Message-ID: <20150228164158.GE5404@thunk.org>
References: <20150210151934.GA11212@phnom.home.cmpxchg.org>
 <201502111123.ICD65197.FMLOHSQJFVOtFO@I-love.SAKURA.ne.jp>
 <201502172123.JIE35470.QOLMVOFJSHOFFt@I-love.SAKURA.ne.jp>
 <20150217125315.GA14287@phnom.home.cmpxchg.org>
 <20150217225430.GJ4251@dastard>
 <20150219102431.GA15569@phnom.home.cmpxchg.org>
 <20150219225217.GY12722@dastard>
 <20150221235227.GA25079@phnom.home.cmpxchg.org>
 <20150223004521.GK12722@dastard>
 <20150228162943.GA17989@phnom.home.cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150228162943.GA17989@phnom.home.cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Dave Chinner <david@fromorbit.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, mhocko@suse.cz, dchinner@redhat.com, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, akpm@linux-foundation.org, mgorman@suse.de, torvalds@linux-foundation.org, xfs@oss.sgi.com

On Sat, Feb 28, 2015 at 11:29:43AM -0500, Johannes Weiner wrote:
> 
> I'm trying to figure out if the current nofail allocators can get
> their memory needs figured out beforehand.  And reliably so - what
> good are estimates that are right 90% of the time, when failing the
> allocation means corrupting user data?  What is the contingency plan?

In the ideal world, we can figure out the exact memory needs
beforehand.  But we live in an imperfect world, and given that block
devices *also* need memory, the answer is "of course not".  We can't
be perfect.  But we can least give some kind of hint, and we can offer
to wait before we get into a situation where we need to loop in
GFP_NOWAIT --- which is the contingency/fallback plan.

I'm sure that's not very satisfying, but it's better than what we have
now.

					- Ted

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
