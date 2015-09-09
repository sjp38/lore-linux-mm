Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id A56466B0038
	for <linux-mm@kvack.org>; Wed,  9 Sep 2015 17:56:01 -0400 (EDT)
Received: by pacfv12 with SMTP id fv12so22067039pac.2
        for <linux-mm@kvack.org>; Wed, 09 Sep 2015 14:56:01 -0700 (PDT)
Received: from mail-pa0-x229.google.com (mail-pa0-x229.google.com. [2607:f8b0:400e:c03::229])
        by mx.google.com with ESMTPS id ht3si13786463pad.70.2015.09.09.14.56.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Sep 2015 14:56:00 -0700 (PDT)
Received: by padhy16 with SMTP id hy16so21788618pad.1
        for <linux-mm@kvack.org>; Wed, 09 Sep 2015 14:56:00 -0700 (PDT)
Date: Wed, 9 Sep 2015 14:55:59 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] android, lmk: Send SIGKILL before setting TIF_MEMDIE.
In-Reply-To: <1441517135-4980-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <alpine.DEB.2.10.1509091454020.20924@chino.kir.corp.google.com>
References: <1441517135-4980-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: gregkh@linuxfoundation.org, mhocko@kernel.org, linux-mm@kvack.org

On Sun, 6 Sep 2015, Tetsuo Handa wrote:

> It was observed that setting TIF_MEMDIE before sending SIGKILL at
> oom_kill_process() allows memory reserves to be depleted by allocations
> which are not needed for terminating the OOM victim.
> 

I don't understand what you are trying to fix.  Sending a SIGKILL first 
does not guarantee that it is handling that signal before accessing memory 
reserves.  I have no objection to the patch, but I don't think it actually 
matters either way and is relatively pointless.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
