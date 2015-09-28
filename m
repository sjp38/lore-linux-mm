Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f170.google.com (mail-io0-f170.google.com [209.85.223.170])
	by kanga.kvack.org (Postfix) with ESMTP id D9AB76B0255
	for <linux-mm@kvack.org>; Mon, 28 Sep 2015 18:28:50 -0400 (EDT)
Received: by ioiz6 with SMTP id z6so191412079ioi.2
        for <linux-mm@kvack.org>; Mon, 28 Sep 2015 15:28:50 -0700 (PDT)
Received: from mail-pa0-x235.google.com (mail-pa0-x235.google.com. [2607:f8b0:400e:c03::235])
        by mx.google.com with ESMTPS id e8si13930748igx.22.2015.09.28.15.28.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Sep 2015 15:28:50 -0700 (PDT)
Received: by pablk4 with SMTP id lk4so88860073pab.3
        for <linux-mm@kvack.org>; Mon, 28 Sep 2015 15:28:50 -0700 (PDT)
Date: Mon, 28 Sep 2015 15:28:48 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: can't oom-kill zap the victim's memory?
In-Reply-To: <201509290118.BCJ43256.tSFFFMOLHVOJOQ@I-love.SAKURA.ne.jp>
Message-ID: <alpine.DEB.2.10.1509281526080.13657@chino.kir.corp.google.com>
References: <20150922160608.GA2716@redhat.com> <20150923205923.GB19054@dhcp22.suse.cz> <alpine.DEB.2.10.1509241359100.32488@chino.kir.corp.google.com> <20150925093556.GF16497@dhcp22.suse.cz> <201509260114.ADI35946.OtHOVFOMJQFLFS@I-love.SAKURA.ne.jp>
 <201509290118.BCJ43256.tSFFFMOLHVOJOQ@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: mhocko@kernel.org, oleg@redhat.com, torvalds@linux-foundation.org, kwalker@redhat.com, cl@linux.com, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, skozina@redhat.com

On Tue, 29 Sep 2015, Tetsuo Handa wrote:

> > The point I've tried to made is that oom unmapper running in a detached
> > context (e.g. kernel thread) vs. directly in the oom context doesn't
> > make any difference wrt. lock because the holders of the lock would loop
> > inside the allocator anyway because we do not fail small allocations.
> 
> We tried to allow small allocations to fail. It resulted in unstable system
> with obscure bugs.
> 

These are helpful to identify regardless of the outcome of this 
discussion.  I'm not sure where the best place to report them would be, 
or whether its even feasible to dig through looking for possibilities, but 
I think it would be interesting to see which callers are relying on 
internal page allocator implementation to work properly since it may 
uncover bugs that would occur later if it were changed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
