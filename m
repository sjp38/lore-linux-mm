Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f179.google.com (mail-ob0-f179.google.com [209.85.214.179])
	by kanga.kvack.org (Postfix) with ESMTP id 79C286B007E
	for <linux-mm@kvack.org>; Tue, 29 Mar 2016 08:52:40 -0400 (EDT)
Received: by mail-ob0-f179.google.com with SMTP id kf9so10696528obc.1
        for <linux-mm@kvack.org>; Tue, 29 Mar 2016 05:52:40 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id w18si12359332otw.70.2016.03.29.05.52.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 29 Mar 2016 05:52:29 -0700 (PDT)
Subject: Re: [PATCH] oom, oom_reaper: Do not enqueue task if it is on the oom_reaper_list head
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1459254686-29457-1-git-send-email-mhocko@kernel.org>
In-Reply-To: <1459254686-29457-1-git-send-email-mhocko@kernel.org>
Message-Id: <201603292152.IBF60927.FJOHMVtOFOFSQL@I-love.SAKURA.ne.jp>
Date: Tue, 29 Mar 2016 21:52:20 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, mhocko@suse.com

Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> bb29902a7515 ("oom, oom_reaper: protect oom_reaper_list using simpler
> way") has simplified the check for tasks already enqueued for the oom
> reaper by checking tsk->oom_reaper_list != NULL. This check is not
> sufficient because the tsk might be the head of the queue without any
> other tasks queued and then we would simply lockup looping on the same
> task. Fix the condition by checking for the head as well.

Indeed, oom_reaper_list is initially NULL.

> 
> Fixes: bb29902a7515 ("oom, oom_reaper: protect oom_reaper_list using simpler way")
> Signed-off-by: Michal Hocko <mhocko@suse.com>
Acked-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

> ---
> Hi,
> I have just noticed this after I started consolidating other oom_reaper
> related changes I have here locally. I should have caught this during
> the review already and I really feel ashamed I haven't because this is
> really a trivial bug that should be obvious see...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
