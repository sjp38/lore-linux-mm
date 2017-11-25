Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id EDD676B0253
	for <linux-mm@kvack.org>; Fri, 24 Nov 2017 20:42:05 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id q101so29176848ioi.12
        for <linux-mm@kvack.org>; Fri, 24 Nov 2017 17:42:05 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id g201si9591996ita.68.2017.11.24.17.42.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 24 Nov 2017 17:42:04 -0800 (PST)
Subject: Re: [PATCH v2 1/2] mm,vmscan: Make unregister_shrinker() no-op if register_shrinker() failed.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1511523385-6433-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20171124122148.qevmiogh3pzr4zix@dhcp22.suse.cz>
	<201711242221.BJD26077.SFOtVQJMFHOOFL@I-love.SAKURA.ne.jp>
	<20171124132857.vi4t7szmbknywng7@dhcp22.suse.cz>
In-Reply-To: <20171124132857.vi4t7szmbknywng7@dhcp22.suse.cz>
Message-Id: <201711251040.IHJ00547.FOFStVJOOMHFLQ@I-love.SAKURA.ne.jp>
Date: Sat, 25 Nov 2017 10:40:13 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, viro@zeniv.linux.org.uk, glauber@scylladb.com, syzkaller@googlegroups.com

Michal Hocko wrote:
> On Fri 24-11-17 22:21:55, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > > Since we can encourage register_shrinker() callers to check for failure
> > > > by marking register_shrinker() as __must_check, unregister_shrinker()
> > > > can stay silent.
> > > 
> > > I am not sure __must_check is the right way. We already do get
> > > allocation warning if the registration fails so silent unregister is
> > > acceptable. Unchecked register_shrinker is a bug like any other
> > > unchecked error path.
> > 
> > I consider that __must_check is the simplest way to find all of
> > unchecked register_shrinker bugs. Why not to encourage users to fix?
> 
> because git grep doesn't require to patch the kernel and still provide
> the information you want.

I can't interpret this line. How git grep relevant?

If all register_shrinker() users were careful enough to check for git history
everytime, we would not have come to current code. It is duty of patch author
to take necessary precautions (for in-tree code) when some API starts to
return an error which previously did not return an error. In this case, it is
duty of author of commit 1d3d4437eae1bb29 ("vmscan: per-node deferred work").

>                           I would understand __must_check if we had
> hundreds users of this api and they come and go quickly.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
