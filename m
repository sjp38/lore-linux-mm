Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id AEFCC6B0275
	for <linux-mm@kvack.org>; Mon,  9 Jul 2018 03:45:39 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id c20-v6so6921631eds.21
        for <linux-mm@kvack.org>; Mon, 09 Jul 2018 00:45:39 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o34-v6si574829edb.336.2018.07.09.00.45.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Jul 2018 00:45:37 -0700 (PDT)
Date: Mon, 9 Jul 2018 09:45:36 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/8] OOM killer/reaper changes for avoiding OOM lockup
 problem.
Message-ID: <20180709074536.GA22049@dhcp22.suse.cz>
References: <201807050305.w653594Q081552@www262.sakura.ne.jp>
 <20180705071740.GC32658@dhcp22.suse.cz>
 <201807060240.w662e7Q1016058@www262.sakura.ne.jp>
 <CA+55aFz87+iXZ_N5jYgo9UFFJ2Tc9dkMLPxwscriAdDKoyF0CA@mail.gmail.com>
 <b1b81935-1a71-8742-a04f-5c81e1deace0@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b1b81935-1a71-8742-a04f-5c81e1deace0@i-love.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>

On Sat 07-07-18 10:12:57, Tetsuo Handa wrote:
[...]
> On 2018/07/06 14:56, Michal Hocko wrote:
> >>> Yes, there is no need to reclaim all pages. OOM is after freeing _some_
> >>> memory after all. But that means further complications down the unmap
> >>> path. I do not really see any reason for that.
> >>
> >> "I do not see reason for that" cannot become a reason direct OOM reaping has to
> >> reclaim all pages at once.
> > 
> > We are not going to polute deep mm guts for unlikely events like oom.
> 
> And since Michal is refusing to make changes for having the balance between
> "direct reclaim by threads waiting for oom_lock" and "indirect reclaim by
> a thread holding oom_lock", we will keep increasing possibility of hitting
> "0 pages per minute". Therefore,
> 
> > If you are afraid of
> > regression and do not want to have your name on the patch then fine. I
> > will post the patch myself and also handle any fallouts.
> 
> PLEASE PLEASE PLEASE DO SO IMMEDIATELY!!!

Curiously enough I've done so back in May [1] just to hear some really
weird arguments (e.g. that I am not solving an unrelated problem in
the memcg oom killer etc) and other changes of yours that were (again)
intermixing different things together. So then I've ended up with [2].

I will resubmit that patch. But please note how your insisting has only
delayed the whole thing. If I were you I would really think twice before
blaming someone from malicious intentions or even refusing good changes
from being merged.

[1] http://lkml.kernel.org/r/20180528124313.GC27180@dhcp22.suse.cz
[2] http://lkml.kernel.org/r/20180601080443.GX15278@dhcp22.suse.cz

-- 
Michal Hocko
SUSE Labs
