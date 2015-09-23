Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 4CF1A6B0253
	for <linux-mm@kvack.org>; Wed, 23 Sep 2015 16:23:15 -0400 (EDT)
Received: by wicge5 with SMTP id ge5so224259687wic.0
        for <linux-mm@kvack.org>; Wed, 23 Sep 2015 13:23:14 -0700 (PDT)
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com. [209.85.212.172])
        by mx.google.com with ESMTPS id p5si3232353wij.75.2015.09.23.13.23.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Sep 2015 13:23:14 -0700 (PDT)
Received: by wicgb1 with SMTP id gb1so222386170wic.1
        for <linux-mm@kvack.org>; Wed, 23 Sep 2015 13:23:13 -0700 (PDT)
Date: Wed, 23 Sep 2015 22:23:11 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, oom: Disable preemption during OOM-kill operation.
Message-ID: <20150923202311.GA19054@dhcp22.suse.cz>
References: <201509191605.CAF13520.QVSFHLtFJOMOOF@I-love.SAKURA.ne.jp>
 <20150922165523.GD4027@dhcp22.suse.cz>
 <201509232326.JEB43777.SOFMJOVOLFFtQH@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201509232326.JEB43777.SOFMJOVOLFFtQH@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: rientjes@google.com, hannes@cmpxchg.org, linux-mm@kvack.org

On Wed 23-09-15 23:26:35, Tetsuo Handa wrote:
[...]
> Sprinkling preempt_{enable,disable} all around the oom path can temporarily
> slow down threads with higher priority. But doing so can guarantee that
> the oom path is not delayed indefinitely. Imagine a scenario where a task
> with idle priority called the oom path and other tasks with normal or
> realtime priority preempt. How long will we hold oom_lock and keep the
> system under oom?

What I've tried to say is that the OOM killer context might get priority
boost to make sure it makes sufficient progress. This would be much more
systematic approach IMO than sprinkling preempt_{enable,disable} all over
the place.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
