Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 535DF6B0005
	for <linux-mm@kvack.org>; Sun,  3 Jul 2016 08:42:55 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id r68so112682716qka.3
        for <linux-mm@kvack.org>; Sun, 03 Jul 2016 05:42:55 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q131si1644363qka.276.2016.07.03.05.42.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 03 Jul 2016 05:42:54 -0700 (PDT)
Date: Sun, 3 Jul 2016 14:42:46 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 1/8] mm,oom_reaper: Remove pointless kthread_run()
 failure check.
Message-ID: <20160703124246.GA23902@redhat.com>
References: <201607031135.AAH95347.MVOHQtFJFLOOFS@I-love.SAKURA.ne.jp>
 <201607031136.GGI52642.OMLFFOHQtFVJOS@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201607031136.GGI52642.OMLFFOHQtFVJOS@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, rientjes@google.com, vdavydov@parallels.com, mst@redhat.com, mhocko@suse.com, mhocko@kernel.org

On 07/03, Tetsuo Handa wrote:
>
> If kthread_run() in oom_init() fails due to reasons other than OOM
> (e.g. no free pid is available), userspace processes won't be able to
> start as well.

Why?

The kernel will boot with or without your change, but

> Therefore, trying to continue with error message is
> also pointless.

Can't understand...

I think this warning makes sense. And since you removed the oom_reaper_the
check in wake_oom_reaper(), the kernel will leak every task_struct passed
to wake_oom_reaper() ?

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
