Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id D45366B0069
	for <linux-mm@kvack.org>; Fri, 24 Nov 2017 08:29:00 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id o20so2641577wro.8
        for <linux-mm@kvack.org>; Fri, 24 Nov 2017 05:29:00 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z54si1658846edc.92.2017.11.24.05.28.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 24 Nov 2017 05:28:59 -0800 (PST)
Date: Fri, 24 Nov 2017 14:28:57 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 1/2] mm,vmscan: Make unregister_shrinker() no-op if
 register_shrinker() failed.
Message-ID: <20171124132857.vi4t7szmbknywng7@dhcp22.suse.cz>
References: <1511523385-6433-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20171124122148.qevmiogh3pzr4zix@dhcp22.suse.cz>
 <201711242221.BJD26077.SFOtVQJMFHOOFL@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201711242221.BJD26077.SFOtVQJMFHOOFL@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, viro@zeniv.linux.org.uk, glauber@scylladb.com, syzkaller@googlegroups.com

On Fri 24-11-17 22:21:55, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > > Since we can encourage register_shrinker() callers to check for failure
> > > by marking register_shrinker() as __must_check, unregister_shrinker()
> > > can stay silent.
> > 
> > I am not sure __must_check is the right way. We already do get
> > allocation warning if the registration fails so silent unregister is
> > acceptable. Unchecked register_shrinker is a bug like any other
> > unchecked error path.
> 
> I consider that __must_check is the simplest way to find all of
> unchecked register_shrinker bugs. Why not to encourage users to fix?

because git grep doesn't require to patch the kernel and still provide
the information you want. I would understand __must_check if we had
hundreds users of this api and they come and go quickly.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
