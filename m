Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 94ABF6B0005
	for <linux-mm@kvack.org>; Wed, 11 May 2016 13:46:37 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id d62so105943643iof.1
        for <linux-mm@kvack.org>; Wed, 11 May 2016 10:46:37 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id a83si5674274itd.7.2016.05.11.10.46.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 May 2016 10:46:36 -0700 (PDT)
Date: Wed, 11 May 2016 19:46:30 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: x86_64 Question: Are concurrent IPI requests safe?
Message-ID: <20160511174630.GI3192@twins.programming.kicks-ass.net>
References: <alpine.DEB.2.11.1605091853130.3540@nanos>
 <201605112219.HEB64012.FLQOFMJOVOtFHS@I-love.SAKURA.ne.jp>
 <20160511133928.GF3192@twins.programming.kicks-ass.net>
 <201605112309.AGJ18252.tOFMFQOJFLSOVH@I-love.SAKURA.ne.jp>
 <alpine.DEB.2.11.1605111631430.3540@nanos>
 <201605120019.CGI60411.OJSLHFQFtVMOOF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201605120019.CGI60411.OJSLHFQFtVMOOF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: tglx@linutronix.de, mingo@kernel.org, akpm@linux-foundation.org, mgorman@techsingularity.net, mhocko@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, May 12, 2016 at 12:19:07AM +0900, Tetsuo Handa wrote:
> Well, I came to feel that this is caused by down_write_killable() bug.
> I guess we should fix down_write_killable() bug first.

There's a patch you can try in that thread...

  lkml.kernel.org/r/20160511094128.GB3190@twins.programming.kicks-ass.net

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
