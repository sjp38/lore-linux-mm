Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 8B96D82F64
	for <linux-mm@kvack.org>; Fri, 30 Oct 2015 22:43:15 -0400 (EDT)
Received: by pasz6 with SMTP id z6so90296655pas.2
        for <linux-mm@kvack.org>; Fri, 30 Oct 2015 19:43:15 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id sh4si15330440pac.159.2015.10.30.19.43.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 30 Oct 2015 19:43:14 -0700 (PDT)
Subject: Re: [patch 3/3] vmstat: Create our own workqueue
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <alpine.DEB.2.20.1510272202120.4647@east.gentwo.org>
	<201510282057.JHI87536.OMOFFFLJOHQtVS@I-love.SAKURA.ne.jp>
	<20151029022447.GB27115@mtj.duckdns.org>
	<20151029030822.GD27115@mtj.duckdns.org>
	<alpine.DEB.2.20.1510292000340.30861@east.gentwo.org>
In-Reply-To: <alpine.DEB.2.20.1510292000340.30861@east.gentwo.org>
Message-Id: <201510311143.BIH87000.tOSVFHOFJMLFOQ@I-love.SAKURA.ne.jp>
Date: Sat, 31 Oct 2015 11:43:00 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux.com
Cc: htejun@gmail.com, akpm@linux-foundation.org, mhocko@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, hannes@cmpxchg.org, mgorman@suse.de

Christoph Lameter wrote:
> On Thu, 29 Oct 2015, Tejun Heo wrote:
> 
> > Wait, this series doesn't include Tetsuo's change.  Of course it won't
> > fix the deadlock problem.  What's necessary is Tetsuo's patch +
> > WQ_MEM_RECLAIM.
> 
> This series is only dealing with vmstat changes. Do I get an ack here?
> 

Then, you need to update below description (or drop it) because
patch 3/3 alone will not guarantee that the counters are up to date.

  Christoph Lameter wrote:
  > Seems that vmstat needs its own workqueue now since the general
  > workqueue mechanism has been *enhanced* which means that the
  > vmstat_updates cannot run reliably but are being blocked by
  > work requests doing memory allocation. Which causes vmstat
  > to be unable to keep the counters up to date.

I am waiting for decision from candidates listed at
http://lkml.kernel.org/r/201510251952.CEF04109.OSOtLFHFVFJMQO@I-love.SAKURA.ne.jp .
If your series is not for backporting, please choose one from
the candidates. Can you accept the original patch at
http://lkml.kernel.org/r/201510212126.JIF90648.HOOFJVFQLMStOF@I-love.SAKURA.ne.jp
which implements (1) from the candidates?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
