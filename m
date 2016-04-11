Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id C3A2C6B025F
	for <linux-mm@kvack.org>; Mon, 11 Apr 2016 08:02:42 -0400 (EDT)
Received: by mail-wm0-f43.google.com with SMTP id v188so83286667wme.1
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 05:02:42 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id bu3si28494776wjc.51.2016.04.11.05.02.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Apr 2016 05:02:40 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id a140so20758875wma.2
        for <linux-mm@kvack.org>; Mon, 11 Apr 2016 05:02:40 -0700 (PDT)
Date: Mon, 11 Apr 2016 14:02:38 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 2/3] oom, oom_reaper: Try to reap tasks which skipregular
 OOM killer path
Message-ID: <20160411120238.GF23157@dhcp22.suse.cz>
References: <1459951996-12875-1-git-send-email-mhocko@kernel.org>
 <1459951996-12875-3-git-send-email-mhocko@kernel.org>
 <201604072038.CHC51027.MSJOFVLHOFFtQO@I-love.SAKURA.ne.jp>
 <201604082019.EDH52671.OJHQFMStOFLVOF@I-love.SAKURA.ne.jp>
 <20160408115033.GH29820@dhcp22.suse.cz>
 <201604091339.FAJ12491.FVHQFFMSJLtOOO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201604091339.FAJ12491.FVHQFFMSJLtOOO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, rientjes@google.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, oleg@redhat.com

On Sat 09-04-16 13:39:30, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Fri 08-04-16 20:19:28, Tetsuo Handa wrote:
> > > I looked at next-20160408 but I again came to think that we should remove
> > > these shortcuts (something like a patch shown bottom).
> >
> > feel free to send the patch with the full description. But I would
> > really encourage you to check the history to learn why those have been
> > added and describe why those concerns are not valid/important anymore.
> 
> I believe that past discussions and decisions about current code are too
> optimistic because they did not take 'The "too small to fail" memory-
> allocation rule' problem into account.

In most cases they were driven by _real_ usecases though. And that
is what matters. Theoretically possible issues which happen under
crazy workloads which are DoSing the machine already are not something
to optimize for. Sure we should try to cope with them as gracefully
as possible, no questions about that, but we should try hard not to
reintroduce previous issues during _sensible_ workloads.

> If you ignore me with "check the history to learn why those have been added
> and describe why those concerns are not valid/important anymore", I can do
> nothing. What are valid/important concerns that have higher priority than
> keeping 'The "too small to fail" memory-allocation rule' problem and continue
> telling a lie to end users? Please enumerate such concerns.

I feel like we are looping in a circle and I do not want to waste my
time repeating arguments which were already mentioned several times. 
I have already told you that you have to justify potentially disruptive
changes properly. So far you are more focused on extreme cases while
you do not seem to care all that much about those which happen most of
the time. We surely do not want to regress there. If I am telling you
to study the history of our heuristics it is to _help_ you understand
why they have been introduced so that you can argue with the reasoning
and/or come up with improvements. Unless you start doing this chances
are that your patches will not see overly warm welcome.

> > Your way of throwing a large patch based on an extreme load which is
> > basically DoSing the machine is not the ideal one.
> 
> You are not paying attention to real world's limitations I'm facing.

So far I haven't seen any _real_world_ example from you, to be honest.
All I can see is hammering the system with some DoS scenarios which
triggered different corner cases in the behavior. Those are good to make
us think about our limitations and think for longterm solutions.

> I have to waste my resource trying to identify and fix on behalf of
> customers before they determine the kernel version to use for their
> systems, for your way of thinking is that "We don't need to worry about
> it because I have never received such report"

No I am not saying that. I am saying that I have never seen a _properly_
configured system to blow up in a way that would trigger pathological
cases you are mentioning. And that is a big difference. You can
misconfigure your system in so many ways and put it on knees without a
way out.

With all due respect I will not continue in this line of discussion
because it doesn't lead anywhere.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
