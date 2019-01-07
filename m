Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8E2D18E0001
	for <linux-mm@kvack.org>; Mon,  7 Jan 2019 08:37:23 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id y35so317676edb.5
        for <linux-mm@kvack.org>; Mon, 07 Jan 2019 05:37:23 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gh5-v6si845779ejb.65.2019.01.07.05.37.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Jan 2019 05:37:22 -0800 (PST)
Date: Mon, 7 Jan 2019 14:37:20 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] memcg: killed threads should not invoke memcg OOM killer
Message-ID: <20190107133720.GH31793@dhcp22.suse.cz>
References: <1545819215-10892-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <f6d97ad3-ab04-f5e2-4822-96eac6ab45da@i-love.sakura.ne.jp>
 <20190107114139.GF31793@dhcp22.suse.cz>
 <b0c4748e-f024-4d5c-a233-63c269660004@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b0c4748e-f024-4d5c-a233-63c269660004@i-love.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Kirill Tkhai <ktkhai@virtuozzo.com>, Linus Torvalds <torvalds@linux-foundation.org>

On Mon 07-01-19 22:07:43, Tetsuo Handa wrote:
> On 2019/01/07 20:41, Michal Hocko wrote:
> > On Sun 06-01-19 15:02:24, Tetsuo Handa wrote:
> >> Michal and Johannes, can we please stop this stupid behavior now?
> > 
> > I have proposed a patch with a much more limited scope which is still
> > waiting for feedback. I haven't heard it wouldn't be working so far.
> > 
> 
> You mean
> 
>   mutex_lock_killable would take care of exiting task already. I would
>   then still prefer to check for mark_oom_victim because that is not racy
>   with the exit path clearing signals. I can update my patch to use
>   _killable lock variant if we are really going with the memcg specific
>   fix.
> 
> ? No response for two months.

I mean http://lkml.kernel.org/r/20181022071323.9550-1-mhocko@kernel.org
which has died in nit picking. I am not very interested to go back there
and spend a lot of time with it again. If you do not respect my opinion
as the maintainer of this code then find somebody else to push it
through.

-- 
Michal Hocko
SUSE Labs
