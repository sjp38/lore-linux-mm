Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 81FC56B0033
	for <linux-mm@kvack.org>; Fri, 13 Jan 2017 06:50:12 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id 127so114513870pfg.5
        for <linux-mm@kvack.org>; Fri, 13 Jan 2017 03:50:12 -0800 (PST)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id m17si12509476pli.290.2017.01.13.03.50.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Jan 2017 03:50:11 -0800 (PST)
Received: by mail-pf0-x241.google.com with SMTP id 127so8162826pfg.0
        for <linux-mm@kvack.org>; Fri, 13 Jan 2017 03:50:11 -0800 (PST)
Date: Fri, 13 Jan 2017 20:50:24 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] mm/page_alloc: Wait for oom_lock before retrying.
Message-ID: <20170113115024.GA16506@jagdpanzerIV.localdomain>
References: <20161220153948.GA575@tigerII.localdomain>
 <201612221927.BGE30207.OSFJMFLFOHQtOV@I-love.SAKURA.ne.jp>
 <20161222134250.GE413@tigerII.localdomain>
 <201612222301.AFG57832.QOFMSVFOJHLOtF@I-love.SAKURA.ne.jp>
 <20161222140930.GF413@tigerII.localdomain>
 <201612261954.FJE69201.OFLVtFJSQFOHMO@I-love.SAKURA.ne.jp>
 <20161226113407.GA515@tigerII.localdomain>
 <20170112141844.GA20462@pathway.suse.cz>
 <20170113022843.GA9360@jagdpanzerIV.localdomain>
 <20170113110323.GH14894@pathway.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170113110323.GH14894@pathway.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, mhocko@suse.com, linux-mm@kvack.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Jiri Slaby <jslaby@suse.cz>, linux-fbdev@vger.kernel.org, linux-kernel@vger.kernel.org

On (01/13/17 12:03), Petr Mladek wrote:
[..]
> > why can't we?
> 
> Because it would newer call cond_resched() in non-preemptive kernel
> with CONFIG_PREEMPT_COUNT disabled. IMHO, we want to call it,
> for example, when we scroll the entire screen from tty_operations.
> 
> Or do I miss anything?

so... basically. it has never called cond_resched() there. right?
why is this suddenly a problem now?

	-ss

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
