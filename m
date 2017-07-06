Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id DEECC6B02F4
	for <linux-mm@kvack.org>; Thu,  6 Jul 2017 06:49:00 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id b130so1290555oii.9
        for <linux-mm@kvack.org>; Thu, 06 Jul 2017 03:49:00 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id w8si1112973oib.158.2017.07.06.03.48.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 06 Jul 2017 03:48:59 -0700 (PDT)
Subject: Re: [PATCH] mm, vmscan: do not loop on too_many_isolated for ever
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20170630133236.GM22917@dhcp22.suse.cz>
	<201707010059.EAE43714.FOVOMOSLFHJFQt@I-love.SAKURA.ne.jp>
	<20170630161907.GC9714@dhcp22.suse.cz>
	<201707012043.BBE32181.JOFtOFVHQMLOFS@I-love.SAKURA.ne.jp>
	<20170705082018.GB14538@dhcp22.suse.cz>
In-Reply-To: <20170705082018.GB14538@dhcp22.suse.cz>
Message-Id: <201707061948.ICJ18763.tVFOQFOHMJFSLO@I-love.SAKURA.ne.jp>
Date: Thu, 6 Jul 2017 19:48:51 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: hannes@cmpxchg.org, riel@redhat.com, akpm@linux-foundation.org, mgorman@suse.de, vbabka@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Sat 01-07-17 20:43:56, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> [...]
> > > It is really hard to pursue this half solution when there is no clear
> > > indication it helps in your testing. So could you try to test with only
> > > this patch on top of the current linux-next tree (or Linus tree) and see
> > > if you can reproduce the problem?
> > 
> > With this patch on top of next-20170630, I no longer hit this problem.
> > (Of course, this is because this patch eliminates the infinite loop.)
> 
> I assume you haven't seen other negative side effects, like unexpected
> OOMs etc... Are you willing to give your Tested-by?

I didn't see other negative side effects.

Tested-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

We need long time for testing this patch at linux-next.git (and I give up
this handy bug for finding other bugs under almost OOM situation).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
