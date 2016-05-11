Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5C53B6B0005
	for <linux-mm@kvack.org>; Wed, 11 May 2016 17:56:34 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id zy2so91125389pac.1
        for <linux-mm@kvack.org>; Wed, 11 May 2016 14:56:34 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id to9si12571089pab.69.2016.05.11.14.56.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 11 May 2016 14:56:33 -0700 (PDT)
Subject: Re: x86_64 Question: Are concurrent IPI requests safe?
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20160511133928.GF3192@twins.programming.kicks-ass.net>
	<201605112309.AGJ18252.tOFMFQOJFLSOVH@I-love.SAKURA.ne.jp>
	<alpine.DEB.2.11.1605111631430.3540@nanos>
	<201605120019.CGI60411.OJSLHFQFtVMOOF@I-love.SAKURA.ne.jp>
	<20160511174630.GI3192@twins.programming.kicks-ass.net>
In-Reply-To: <20160511174630.GI3192@twins.programming.kicks-ass.net>
Message-Id: <201605120656.BHB73494.tOFMOFOLFQHVJS@I-love.SAKURA.ne.jp>
Date: Thu, 12 May 2016 06:56:25 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org
Cc: tglx@linutronix.de, mingo@kernel.org, akpm@linux-foundation.org, mgorman@techsingularity.net, mhocko@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Peter Zijlstra wrote:
> On Thu, May 12, 2016 at 12:19:07AM +0900, Tetsuo Handa wrote:
> > Well, I came to feel that this is caused by down_write_killable() bug.
> > I guess we should fix down_write_killable() bug first.
> 
> There's a patch you can try in that thread...
> 
>   lkml.kernel.org/r/20160511094128.GB3190@twins.programming.kicks-ass.net
> 

OK. Applying that patch on next-20160511 seems to fix this problem.
Please send it to linux-next tree. Thank you.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
