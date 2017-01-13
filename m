Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 298226B0069
	for <linux-mm@kvack.org>; Fri, 13 Jan 2017 07:15:40 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id l2so15422974wml.5
        for <linux-mm@kvack.org>; Fri, 13 Jan 2017 04:15:40 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b9si11023833wrd.48.2017.01.13.04.15.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 13 Jan 2017 04:15:38 -0800 (PST)
Date: Fri, 13 Jan 2017 13:15:36 +0100
From: Petr Mladek <pmladek@suse.com>
Subject: Re: [PATCH] mm/page_alloc: Wait for oom_lock before retrying.
Message-ID: <20170113121536.GK14894@pathway.suse.cz>
References: <201612221927.BGE30207.OSFJMFLFOHQtOV@I-love.SAKURA.ne.jp>
 <20161222134250.GE413@tigerII.localdomain>
 <201612222301.AFG57832.QOFMSVFOJHLOtF@I-love.SAKURA.ne.jp>
 <20161222140930.GF413@tigerII.localdomain>
 <201612261954.FJE69201.OFLVtFJSQFOHMO@I-love.SAKURA.ne.jp>
 <20161226113407.GA515@tigerII.localdomain>
 <20170112141844.GA20462@pathway.suse.cz>
 <20170113022843.GA9360@jagdpanzerIV.localdomain>
 <20170113110323.GH14894@pathway.suse.cz>
 <20170113115024.GA16506@jagdpanzerIV.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170113115024.GA16506@jagdpanzerIV.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, mhocko@suse.com, linux-mm@kvack.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Jiri Slaby <jslaby@suse.cz>, linux-fbdev@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri 2017-01-13 20:50:24, Sergey Senozhatsky wrote:
> On (01/13/17 12:03), Petr Mladek wrote:
> [..]
> > > why can't we?
> > 
> > Because it would newer call cond_resched() in non-preemptive kernel
> > with CONFIG_PREEMPT_COUNT disabled. IMHO, we want to call it,
> > for example, when we scroll the entire screen from tty_operations.
> > 
> > Or do I miss anything?
> 
> so... basically. it has never called cond_resched() there. right?
> why is this suddenly a problem now?

But it called cond_resched() when the very same code was called
from tty operations under console_lock() that forced
console_may_schedule = 1;

It will never call cond_resched() from the tty operations
when CONFIG_PREEMPT_COUNT is disabled and we try to detect
the preemption automatically.

Best Regards,
Petr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
