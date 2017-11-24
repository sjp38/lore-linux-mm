Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 26BFB6B0033
	for <linux-mm@kvack.org>; Fri, 24 Nov 2017 08:26:08 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id 72so10372257itl.1
        for <linux-mm@kvack.org>; Fri, 24 Nov 2017 05:26:08 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id z126si9478445itg.60.2017.11.24.05.26.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 24 Nov 2017 05:26:06 -0800 (PST)
Subject: Re: [PATCH v2 2/2] mm,vmscan: Mark register_shrinker() as __must_check
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1511523385-6433-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<1511523385-6433-2-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20171124122410.s7lyzfmkhlm6awes@dhcp22.suse.cz>
In-Reply-To: <20171124122410.s7lyzfmkhlm6awes@dhcp22.suse.cz>
Message-Id: <201711242226.BAC04642.FHOFSOLtOJVFMQ@I-love.SAKURA.ne.jp>
Date: Fri, 24 Nov 2017 22:26:03 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, viro@zeniv.linux.org.uk, glauber@scylladb.com

Michal Hocko wrote:
> As already pointed out, I do not think this is worth it. This function
> is no different than many others which need error handling. The system
> will work suboptimally when the shrinker is missing, no question about
> that, but there is no immediate blow up otherwise. It is not all that
> hard to find all those places and fix them up. We do not have hundreds
> of them...

The system might blow up after two years of uptime. For enterprise systems
which try to avoid reboots as much as possible, it is important to fix
known bugs before deploying.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
