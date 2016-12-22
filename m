Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8FBDA28025E
	for <linux-mm@kvack.org>; Thu, 22 Dec 2016 09:30:24 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id g1so414097775pgn.3
        for <linux-mm@kvack.org>; Thu, 22 Dec 2016 06:30:24 -0800 (PST)
Received: from mail-pg0-x242.google.com (mail-pg0-x242.google.com. [2607:f8b0:400e:c05::242])
        by mx.google.com with ESMTPS id x27si30969215pff.112.2016.12.22.06.30.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Dec 2016 06:30:23 -0800 (PST)
Received: by mail-pg0-x242.google.com with SMTP id w68so14320565pgw.3
        for <linux-mm@kvack.org>; Thu, 22 Dec 2016 06:30:23 -0800 (PST)
Date: Thu, 22 Dec 2016 23:30:08 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [PATCH] mm/page_alloc: Wait for oom_lock before retrying.
Message-ID: <20161222143008.GG413@tigerII.localdomain>
References: <201612192025.IFF13034.HJSFLtOFFMQOOV@I-love.SAKURA.ne.jp>
 <20161219122738.GB427@tigerII.localdomain>
 <20161220153948.GA575@tigerII.localdomain>
 <201612221927.BGE30207.OSFJMFLFOHQtOV@I-love.SAKURA.ne.jp>
 <20161222134250.GE413@tigerII.localdomain>
 <201612222301.AFG57832.QOFMSVFOJHLOtF@I-love.SAKURA.ne.jp>
 <20161222140930.GF413@tigerII.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161222140930.GF413@tigerII.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, mhocko@suse.com, linux-mm@kvack.org, pmladek@suse.cz

On (12/22/16 23:09), Sergey Senozhatsky wrote:
> > "404 The page you're looking for could not be found."
> > 
> > Anonymous access not supported?

https://github.com/sergey-senozhatsky/linux-next-ss/commits/printk-safe-deferred

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
