Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8978D6B0003
	for <linux-mm@kvack.org>; Tue, 16 Oct 2018 07:17:10 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id h48-v6so13737482edh.22
        for <linux-mm@kvack.org>; Tue, 16 Oct 2018 04:17:10 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h15-v6si4255520ejq.203.2018.10.16.04.17.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Oct 2018 04:17:09 -0700 (PDT)
Date: Tue, 16 Oct 2018 13:17:07 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] memcg, oom: throttle dump_header for memcg ooms
 without eligible tasks
Message-ID: <20181016111707.GS18839@dhcp22.suse.cz>
References: <6c0a57b3-bfd4-d832-b0bd-5dd3bcae460e@i-love.sakura.ne.jp>
 <20181015133524.GM18839@dhcp22.suse.cz>
 <201810160055.w9G0t62E045154@www262.sakura.ne.jp>
 <20181016092043.GP18839@dhcp22.suse.cz>
 <59b9bd23-ff75-0488-fd96-68ee7f049d00@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <59b9bd23-ff75-0488-fd96-68ee7f049d00@i-love.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, syzkaller-bugs@googlegroups.com, guro@fb.com, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, rientjes@google.com, yang.s@alibaba-inc.com, Andrew Morton <akpm@linux-foundation.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Steven Rostedt <rostedt@goodmis.org>

On Tue 16-10-18 20:05:47, Tetsuo Handa wrote:
> On 2018/10/16 18:20, Michal Hocko wrote:
> >> Anyway, I'm OK if we apply _BOTH_ your patch and my patch. Or I'm OK with simplified
> >> one shown below (because you don't like per memcg limit).
> > 
> > My patch is adding a rate-limit! I really fail to see why we need yet
> > another one on top of it. This is just ridiculous. I can see reasons to
> > tune that rate limit but adding 2 different mechanisms is just wrong.
> > 
> > If your NAK to unify the ratelimit for dump_header for all paths
> > still holds then I do not care too much to push it forward. But I find
> > thiis way of the review feedback counter productive.
> > 
> 
> Your patch is _NOT_ adding a rate-limit for
> 
>   "%s invoked oom-killer: gfp_mask=%#x(%pGg), nodemask=%*pbl, order=%d, oom_score_adj=%hd\n"
>   "Out of memory and no killable processes...\n"
> 
> lines!

And I've said I do not have objections to have an _incremental_ patch to
move the ratelimit up with a clear cost/benefit evaluation.
-- 
Michal Hocko
SUSE Labs
