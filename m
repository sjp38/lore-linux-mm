Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 76DE76B0421
	for <linux-mm@kvack.org>; Thu, 22 Dec 2016 09:01:36 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id a190so363325476pgc.0
        for <linux-mm@kvack.org>; Thu, 22 Dec 2016 06:01:36 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id w76si30867284pfa.220.2016.12.22.06.01.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 22 Dec 2016 06:01:35 -0800 (PST)
Subject: Re: [PATCH] mm/page_alloc: Wait for oom_lock before retrying.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201612192025.IFF13034.HJSFLtOFFMQOOV@I-love.SAKURA.ne.jp>
	<20161219122738.GB427@tigerII.localdomain>
	<20161220153948.GA575@tigerII.localdomain>
	<201612221927.BGE30207.OSFJMFLFOHQtOV@I-love.SAKURA.ne.jp>
	<20161222134250.GE413@tigerII.localdomain>
In-Reply-To: <20161222134250.GE413@tigerII.localdomain>
Message-Id: <201612222301.AFG57832.QOFMSVFOJHLOtF@I-love.SAKURA.ne.jp>
Date: Thu, 22 Dec 2016 23:01:25 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sergey.senozhatsky@gmail.com
Cc: mhocko@suse.com, linux-mm@kvack.org, pmladek@suse.cz

Sergey Senozhatsky wrote:
> On (12/22/16 19:27), Tetsuo Handa wrote:
> > Thank you. I tried "[PATCHv6 0/7] printk: use printk_safe to handle printk()
> > recursive calls" at https://lkml.org/lkml/2016/12/21/232 on top of linux.git
> > as of commit 52bce91165e5f2db "splice: reinstate SIGPIPE/EPIPE handling", but
> > it turned out that your patch set does not solve this problem.
> > 
> > I was assuming that sending to consoles from printk() is offloaded to a kernel
> > thread dedicated for that purpose, but your patch set does not do it.
> 
> sorry, seems that I didn't deliver the information properly.
> 
> https://gitlab.com/senozhatsky/linux-next-ss/commits/printk-safe-deferred
> 
> there are 2 patch sets. the first one is printk-safe. the second one
> is async printk.
> 
> 9 patches in total (as of now).
> 
> can you access it?

"404 The page you're looking for could not be found."

Anonymous access not supported?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
