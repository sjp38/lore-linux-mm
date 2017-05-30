Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id C74B86B02C3
	for <linux-mm@kvack.org>; Tue, 30 May 2017 09:17:30 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id h76so95108595pfh.15
        for <linux-mm@kvack.org>; Tue, 30 May 2017 06:17:30 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id g21si42975031plj.36.2017.05.30.06.17.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 30 May 2017 06:17:29 -0700 (PDT)
Subject: Re: [PATCH] mm,oom: add tracepoints for oom reaper-related events
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1496145932-18636-1-git-send-email-guro@fb.com>
	<20170530123415.GF7969@dhcp22.suse.cz>
In-Reply-To: <20170530123415.GF7969@dhcp22.suse.cz>
Message-Id: <201705302217.JAI21823.FOFJtOQVOHLMSF@I-love.SAKURA.ne.jp>
Date: Tue, 30 May 2017 22:17:11 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, guro@fb.com
Cc: hannes@cmpxchg.org, vdavydov.dev@gmail.com, kernel-team@fb.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Michal Hocko wrote:
> On Tue 30-05-17 13:05:32, Roman Gushchin wrote:
> > Add tracepoints to simplify the debugging of the oom reaper code.
> > 
> > Trace the following events:
> > 1) a process is marked as an oom victim,
> > 2) a process is added to the oom reaper list,
> > 3) the oom reaper starts reaping process's mm,
> > 4) the oom reaper finished reaping,
> > 5) the oom reaper skips reaping.
> 
> I am not against but could you explain why the current printks are not
> sufficient? We do not have any explicit printk for the 2) and 3) but
> are those really necessary?
> 
> In other words could you describe the situation when you found these
> tracepoints more useful than what the kernel log offers already?

Guessing from "to simplify the debugging of the oom reaper code",
Roman is facing some unknown bugs or problems?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
