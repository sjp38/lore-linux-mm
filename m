Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id D75196B0253
	for <linux-mm@kvack.org>; Wed,  7 Oct 2015 06:43:18 -0400 (EDT)
Received: by pacfv12 with SMTP id fv12so18501397pac.2
        for <linux-mm@kvack.org>; Wed, 07 Oct 2015 03:43:18 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id fy5si56830783pbb.14.2015.10.07.03.43.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 07 Oct 2015 03:43:18 -0700 (PDT)
Subject: Re: can't oom-kill zap the victim's memory?
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201509290118.BCJ43256.tSFFFMOLHVOJOQ@I-love.SAKURA.ne.jp>
	<20151002123639.GA13914@dhcp22.suse.cz>
	<CA+55aFw=OLSdh-5Ut2vjy=4Yf1fTXqpzoDHdF7XnT5gDHs6sYA@mail.gmail.com>
	<20151005144404.GD7023@dhcp22.suse.cz>
	<5614AAC0.60002@suse.cz>
In-Reply-To: <5614AAC0.60002@suse.cz>
Message-Id: <201510071943.DCJ01080.JOFOFFOtLSMQHV@I-love.SAKURA.ne.jp>
Date: Wed, 7 Oct 2015 19:43:08 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: vbabka@suse.cz
Cc: mhocko@kernel.org, torvalds@linux-foundation.org, rientjes@google.com, oleg@redhat.com, kwalker@redhat.com, cl@linux.com, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, skozina@redhat.com

Vlastimil Babka wrote:
> On 5.10.2015 16:44, Michal Hocko wrote:
> > So I can see basically only few ways out of this deadlock situation.
> > Either we face the reality and allow small allocations (withtout
> > __GFP_NOFAIL) to fail after all attempts to reclaim memory have failed
> > (so after even OOM killer hasn't made any progress).
> 
> Note that small allocations already *can* fail if they are done in the context
> of a task selected as OOM victim (i.e. TIF_MEMDIE). And yeah I've seen a case
> when they failed in a code that "handled" the allocation failure with a
> BUG_ON(!page).
> 
Did You hit a race described below?
http://lkml.kernel.org/r/201508272249.HDH81838.FtQOLMFFOVSJOH@I-love.SAKURA.ne.jp

Where was the BUG_ON(!page) ? Maybe it is a candidate for adding __GFP_NOFAIL.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
