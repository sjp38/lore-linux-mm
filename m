Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7B9EF6B0333
	for <linux-mm@kvack.org>; Tue, 20 Dec 2016 10:40:09 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id g1so258249223pgn.3
        for <linux-mm@kvack.org>; Tue, 20 Dec 2016 07:40:09 -0800 (PST)
Received: from mail-pg0-x244.google.com (mail-pg0-x244.google.com. [2607:f8b0:400e:c05::244])
        by mx.google.com with ESMTPS id m68si22655504pga.16.2016.12.20.07.40.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Dec 2016 07:40:08 -0800 (PST)
Received: by mail-pg0-x244.google.com with SMTP id i5so2825169pgh.2
        for <linux-mm@kvack.org>; Tue, 20 Dec 2016 07:40:08 -0800 (PST)
Date: Wed, 21 Dec 2016 00:39:48 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [PATCH] mm/page_alloc: Wait for oom_lock before retrying.
Message-ID: <20161220153948.GA575@tigerII.localdomain>
References: <201612142037.AAC60483.HVOSOJFLMOFtQF@I-love.SAKURA.ne.jp>
 <20161214124231.GI25573@dhcp22.suse.cz>
 <201612150136.GBC13980.FHQFLSOJOFOtVM@I-love.SAKURA.ne.jp>
 <20161214181850.GC16763@dhcp22.suse.cz>
 <201612151921.CBE43202.SFLtOFJMOFOQVH@I-love.SAKURA.ne.jp>
 <201612192025.IFF13034.HJSFLtOFFMQOOV@I-love.SAKURA.ne.jp>
 <20161219122738.GB427@tigerII.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161219122738.GB427@tigerII.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, mhocko@suse.com, linux-mm@kvack.org, pmladek@suse.cz

On (12/19/16 21:27), Sergey Senozhatsky wrote:
[..]
> 
> I'll finish re-basing the patch set tomorrow.
> 

pushed

https://gitlab.com/senozhatsky/linux-next-ss/commits/printk-safe-deferred

not tested. will test and send out the patch set tomorrow.

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
