Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id EE33D6B041D
	for <linux-mm@kvack.org>; Thu, 22 Dec 2016 08:43:05 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id j128so359830285pfg.4
        for <linux-mm@kvack.org>; Thu, 22 Dec 2016 05:43:05 -0800 (PST)
Received: from mail-pg0-x243.google.com (mail-pg0-x243.google.com. [2607:f8b0:400e:c05::243])
        by mx.google.com with ESMTPS id s66si30831154pfk.80.2016.12.22.05.43.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Dec 2016 05:43:05 -0800 (PST)
Received: by mail-pg0-x243.google.com with SMTP id g1so18411659pgn.0
        for <linux-mm@kvack.org>; Thu, 22 Dec 2016 05:43:05 -0800 (PST)
Date: Thu, 22 Dec 2016 22:42:50 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [PATCH] mm/page_alloc: Wait for oom_lock before retrying.
Message-ID: <20161222134250.GE413@tigerII.localdomain>
References: <20161214181850.GC16763@dhcp22.suse.cz>
 <201612151921.CBE43202.SFLtOFJMOFOQVH@I-love.SAKURA.ne.jp>
 <201612192025.IFF13034.HJSFLtOFFMQOOV@I-love.SAKURA.ne.jp>
 <20161219122738.GB427@tigerII.localdomain>
 <20161220153948.GA575@tigerII.localdomain>
 <201612221927.BGE30207.OSFJMFLFOHQtOV@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201612221927.BGE30207.OSFJMFLFOHQtOV@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: sergey.senozhatsky@gmail.com, mhocko@suse.com, linux-mm@kvack.org, pmladek@suse.cz

On (12/22/16 19:27), Tetsuo Handa wrote:
> Thank you. I tried "[PATCHv6 0/7] printk: use printk_safe to handle printk()
> recursive calls" at https://lkml.org/lkml/2016/12/21/232 on top of linux.git
> as of commit 52bce91165e5f2db "splice: reinstate SIGPIPE/EPIPE handling", but
> it turned out that your patch set does not solve this problem.
> 
> I was assuming that sending to consoles from printk() is offloaded to a kernel
> thread dedicated for that purpose, but your patch set does not do it.

sorry, seems that I didn't deliver the information properly.

https://gitlab.com/senozhatsky/linux-next-ss/commits/printk-safe-deferred

there are 2 patch sets. the first one is printk-safe. the second one
is async printk.

9 patches in total (as of now).

can you access it?

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
