Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3D7A06B02F3
	for <linux-mm@kvack.org>; Wed,  5 Jul 2017 04:20:23 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id i127so21859882wma.15
        for <linux-mm@kvack.org>; Wed, 05 Jul 2017 01:20:23 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 126si15189840wmz.192.2017.07.05.01.20.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 05 Jul 2017 01:20:21 -0700 (PDT)
Date: Wed, 5 Jul 2017 10:20:19 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, vmscan: do not loop on too_many_isolated for ever
Message-ID: <20170705082018.GB14538@dhcp22.suse.cz>
References: <201703102044.DBJ04626.FLVMFOQOJtOFHS@I-love.SAKURA.ne.jp>
 <201706300914.CEH95859.FMQOLVFHJFtOOS@I-love.SAKURA.ne.jp>
 <20170630133236.GM22917@dhcp22.suse.cz>
 <201707010059.EAE43714.FOVOMOSLFHJFQt@I-love.SAKURA.ne.jp>
 <20170630161907.GC9714@dhcp22.suse.cz>
 <201707012043.BBE32181.JOFtOFVHQMLOFS@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201707012043.BBE32181.JOFtOFVHQMLOFS@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: hannes@cmpxchg.org, riel@redhat.com, akpm@linux-foundation.org, mgorman@suse.de, vbabka@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat 01-07-17 20:43:56, Tetsuo Handa wrote:
> Michal Hocko wrote:
[...]
> > It is really hard to pursue this half solution when there is no clear
> > indication it helps in your testing. So could you try to test with only
> > this patch on top of the current linux-next tree (or Linus tree) and see
> > if you can reproduce the problem?
> 
> With this patch on top of next-20170630, I no longer hit this problem.
> (Of course, this is because this patch eliminates the infinite loop.)

I assume you haven't seen other negative side effects, like unexpected
OOMs etc... Are you willing to give your Tested-by?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
