Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id D04136B028F
	for <linux-mm@kvack.org>; Mon, 19 Dec 2016 07:27:53 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id i88so218558832pfk.3
        for <linux-mm@kvack.org>; Mon, 19 Dec 2016 04:27:53 -0800 (PST)
Received: from mail-pg0-x242.google.com (mail-pg0-x242.google.com. [2607:f8b0:400e:c05::242])
        by mx.google.com with ESMTPS id u89si18175889pfg.283.2016.12.19.04.27.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Dec 2016 04:27:53 -0800 (PST)
Received: by mail-pg0-x242.google.com with SMTP id p66so18374493pga.2
        for <linux-mm@kvack.org>; Mon, 19 Dec 2016 04:27:53 -0800 (PST)
Date: Mon, 19 Dec 2016 21:27:38 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [PATCH] mm/page_alloc: Wait for oom_lock before retrying.
Message-ID: <20161219122738.GB427@tigerII.localdomain>
References: <201612142037.AAC60483.HVOSOJFLMOFtQF@I-love.SAKURA.ne.jp>
 <20161214124231.GI25573@dhcp22.suse.cz>
 <201612150136.GBC13980.FHQFLSOJOFOtVM@I-love.SAKURA.ne.jp>
 <20161214181850.GC16763@dhcp22.suse.cz>
 <201612151921.CBE43202.SFLtOFJMOFOQVH@I-love.SAKURA.ne.jp>
 <201612192025.IFF13034.HJSFLtOFFMQOOV@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201612192025.IFF13034.HJSFLtOFFMQOOV@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: mhocko@suse.com, linux-mm@kvack.org, pmladek@suse.cz, sergey.senozhatsky@gmail.com

On (12/19/16 20:25), Tetsuo Handa wrote:
[..]
> So, I'd like to check whether async printk() can prevent the system from reaching
> the threshold. Though, I guess async printk() won't help for preemption outside
> printk() (i.e. CONFIG_PREEMPT=y and/or longer sleep by schedule_timeout_killable(1)
> after returning from oom_kill_process()).
> 
> Sergey, will you share your async printk() patches?

Hello,

I don't have (yet) a re-based version, since printk has changed a lot
once again during this merge window.

the work is in progress now.

the latest publicly available version is against the linux-next 20161202

https://gitlab.com/senozhatsky/linux-next-ss/commits/printk-safe-deferred


I'll finish re-basing the patch set tomorrow.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
