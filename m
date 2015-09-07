Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f174.google.com (mail-ob0-f174.google.com [209.85.214.174])
	by kanga.kvack.org (Postfix) with ESMTP id 4E8596B0038
	for <linux-mm@kvack.org>; Mon,  7 Sep 2015 12:51:18 -0400 (EDT)
Received: by obuk4 with SMTP id k4so65636099obu.2
        for <linux-mm@kvack.org>; Mon, 07 Sep 2015 09:51:18 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id z3si298455oiz.87.2015.09.07.09.51.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 07 Sep 2015 09:51:17 -0700 (PDT)
Subject: Re: [RFC 0/8] Allow GFP_NOFS allocation to fail
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1438768284-30927-1-git-send-email-mhocko@kernel.org>
In-Reply-To: <1438768284-30927-1-git-send-email-mhocko@kernel.org>
Message-Id: <201509080151.HDD35430.QtOMHSFLFVOJOF@I-love.SAKURA.ne.jp>
Date: Tue, 8 Sep 2015 01:51:03 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, akpm@linux-foundation.org, hannes@cmpxchg.org, david@fromorbit.com, tytso@mit.edu, jack@suse.cz

Michal Hocko wrote:
> As the VM cannot do much about these requests we should face the reality
> and allow those allocations to fail. Johannes has already posted the
> patch which does that (http://marc.info/?l=linux-mm&m=142726428514236&w=2)
> but the discussion died pretty quickly.

Addition of __GFP_NOFAIL to some locations is accepted, but otherwise
this patchset seems to be stalled.

> With all the patches applied none of the 4 filesystems gets aborted
> transactions and RO remount (well xfs didn't need any special
> treatment). This is obviously not sufficient to claim that failing
> GFP_NOFS is OK now but I think it is a good start for the further
> discussion. I would be grateful if FS people could have a look at those
> patches.  I have simply used __GFP_NOFAIL in the critical paths. This
> might be not the best strategy but it sounds like a good first step.

I posted my comment at
https://osdn.jp/projects/tomoyo/lists/archive/users-en/2015-September/000630.html .

> The third patch allows GFP_NOFS to fail and I believe it should see much
> more testing coverage. It would be really great if it could sit in the
> mmotm tree for few release cycles so that we can catch more fallouts.

Guessing from responses to this patchset, sitting in the mmotm tree can
hardly acquire testing coverage. Also, FS is not the only location that
needs to be tested. If you really want to push "GFP_NOFS can fail" patch,
I think you need to make a lot of effort to encourage kernel developers to
test using mandatory fault injection.

> Thoughts? Opinions?

To me, fixing callers (adding __GFP_NORETRY to callers) in a step-by-step
fashion after adding proactive countermeasure sounds better than changing
the default behavior (implicitly applying __GFP_NORETRY inside).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
