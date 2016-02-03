Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f178.google.com (mail-pf0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id D88AA82963
	for <linux-mm@kvack.org>; Wed,  3 Feb 2016 18:26:45 -0500 (EST)
Received: by mail-pf0-f178.google.com with SMTP id o185so22364360pfb.1
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 15:26:45 -0800 (PST)
Received: from mail-pf0-x235.google.com (mail-pf0-x235.google.com. [2607:f8b0:400e:c00::235])
        by mx.google.com with ESMTPS id a78si12145760pfj.116.2016.02.03.15.26.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Feb 2016 15:26:45 -0800 (PST)
Received: by mail-pf0-x235.google.com with SMTP id n128so22201626pfn.3
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 15:26:45 -0800 (PST)
Date: Wed, 3 Feb 2016 15:26:43 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm,oom: make oom_killer_disable() killable.
In-Reply-To: <1453564040-7492-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <alpine.DEB.2.10.1602031526300.10331@chino.kir.corp.google.com>
References: <1453564040-7492-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: linux-mm@kvack.org

On Sun, 24 Jan 2016, Tetsuo Handa wrote:

> While oom_killer_disable() is called by freeze_processes() after all user
> threads except the current thread are frozen, it is possible that kernel
> threads invoke the OOM killer and sends SIGKILL to the current thread due
> to sharing the thawed victim's memory. Therefore, checking for SIGKILL is
> preferable than TIF_MEMDIE.
> 
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
