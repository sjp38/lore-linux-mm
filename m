Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id C7D576B025F
	for <linux-mm@kvack.org>; Fri, 24 Nov 2017 08:37:53 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id 199so15869972pgg.20
        for <linux-mm@kvack.org>; Fri, 24 Nov 2017 05:37:53 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bc11si17986202plb.422.2017.11.24.05.37.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 24 Nov 2017 05:37:52 -0800 (PST)
Date: Fri, 24 Nov 2017 14:37:51 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2 2/2] mm,vmscan: Mark register_shrinker() as
 __must_check
Message-ID: <20171124133751.jex6yktizmkl435d@dhcp22.suse.cz>
References: <1511523385-6433-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <1511523385-6433-2-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20171124122410.s7lyzfmkhlm6awes@dhcp22.suse.cz>
 <201711242226.BAC04642.FHOFSOLtOJVFMQ@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201711242226.BAC04642.FHOFSOLtOJVFMQ@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, viro@zeniv.linux.org.uk, glauber@scylladb.com

On Fri 24-11-17 22:26:03, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > As already pointed out, I do not think this is worth it. This function
> > is no different than many others which need error handling. The system
> > will work suboptimally when the shrinker is missing, no question about
> > that, but there is no immediate blow up otherwise. It is not all that
> > hard to find all those places and fix them up. We do not have hundreds
> > of them...
> 
> The system might blow up after two years of uptime. For enterprise systems
> which try to avoid reboots as much as possible, it is important to fix
> known bugs before deploying.

And how exactly __must_check help here? Seriously, if you really _care_
then make sure to fix those rather than add dubious code and keep
arguing over it.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
