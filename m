Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 2330B6B0254
	for <linux-mm@kvack.org>; Tue,  1 Sep 2015 18:28:44 -0400 (EDT)
Received: by paap5 with SMTP id p5so1833651paa.0
        for <linux-mm@kvack.org>; Tue, 01 Sep 2015 15:28:43 -0700 (PDT)
Received: from mail-pa0-x234.google.com (mail-pa0-x234.google.com. [2607:f8b0:400e:c03::234])
        by mx.google.com with ESMTPS id a6si20171666pbu.198.2015.09.01.15.28.43
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Sep 2015 15:28:43 -0700 (PDT)
Received: by pacfv12 with SMTP id fv12so9408653pac.2
        for <linux-mm@kvack.org>; Tue, 01 Sep 2015 15:28:43 -0700 (PDT)
Date: Tue, 1 Sep 2015 15:28:41 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/2] android, lmk: Protect task->comm with task_lock.
In-Reply-To: <201508262117.FAH43726.tOFMVJSLQOFHFO@I-love.SAKURA.ne.jp>
Message-ID: <alpine.DEB.2.10.1509011527500.11913@chino.kir.corp.google.com>
References: <201508262117.FAH43726.tOFMVJSLQOFHFO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: gregkh@linuxfoundation.org, arve@android.com, riandrews@android.com, devel@driverdev.osuosl.org, linux-mm@kvack.org, mhocko@kernel.org, hannes@cmpxchg.org

On Wed, 26 Aug 2015, Tetsuo Handa wrote:

> Hello.
> 
> Next patch is mm-related but this patch is not.
> Via which tree should these patches go?
> ----------------------------------------
> >From 48c1b457eb32d7a029e9a078ee0a67974ada9261 Mon Sep 17 00:00:00 2001
> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Date: Wed, 26 Aug 2015 20:49:17 +0900
> Subject: [PATCH 1/2] android, lmk: Protect task->comm with task_lock.
> 
> Passing task->comm to printk() wants task_lock() protection in order
> to avoid potentially emitting garbage bytes.
> 
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

We've gone through these types of patches before and Andrew has said that 
we aren't necessarily concerned with protecting task->comm here since the 
worst-case scenario is that it becomes truncated.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
