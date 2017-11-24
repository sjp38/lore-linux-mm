Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id B84236B0033
	for <linux-mm@kvack.org>; Fri, 24 Nov 2017 08:22:05 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id a72so13089103ioe.13
        for <linux-mm@kvack.org>; Fri, 24 Nov 2017 05:22:05 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id d8si17446326ioe.241.2017.11.24.05.22.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 24 Nov 2017 05:22:04 -0800 (PST)
Subject: Re: [PATCH v2 1/2] mm,vmscan: Make unregister_shrinker() no-op if register_shrinker() failed.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1511523385-6433-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20171124122148.qevmiogh3pzr4zix@dhcp22.suse.cz>
In-Reply-To: <20171124122148.qevmiogh3pzr4zix@dhcp22.suse.cz>
Message-Id: <201711242221.BJD26077.SFOtVQJMFHOOFL@I-love.SAKURA.ne.jp>
Date: Fri, 24 Nov 2017 22:21:55 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, viro@zeniv.linux.org.uk, glauber@scylladb.com, syzkaller@googlegroups.com

Michal Hocko wrote:
> > Since we can encourage register_shrinker() callers to check for failure
> > by marking register_shrinker() as __must_check, unregister_shrinker()
> > can stay silent.
> 
> I am not sure __must_check is the right way. We already do get
> allocation warning if the registration fails so silent unregister is
> acceptable. Unchecked register_shrinker is a bug like any other
> unchecked error path.

I consider that __must_check is the simplest way to find all of
unchecked register_shrinker bugs. Why not to encourage users to fix?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
