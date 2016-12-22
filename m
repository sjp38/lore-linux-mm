Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id C699E6B0423
	for <linux-mm@kvack.org>; Thu, 22 Dec 2016 09:09:46 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id u5so24956179pgi.7
        for <linux-mm@kvack.org>; Thu, 22 Dec 2016 06:09:46 -0800 (PST)
Received: from mail-pf0-x243.google.com (mail-pf0-x243.google.com. [2607:f8b0:400e:c00::243])
        by mx.google.com with ESMTPS id w90si30900724pfk.54.2016.12.22.06.09.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Dec 2016 06:09:45 -0800 (PST)
Received: by mail-pf0-x243.google.com with SMTP id c4so12550364pfb.3
        for <linux-mm@kvack.org>; Thu, 22 Dec 2016 06:09:45 -0800 (PST)
Date: Thu, 22 Dec 2016 23:09:30 +0900
From: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
Subject: Re: [PATCH] mm/page_alloc: Wait for oom_lock before retrying.
Message-ID: <20161222140930.GF413@tigerII.localdomain>
References: <201612192025.IFF13034.HJSFLtOFFMQOOV@I-love.SAKURA.ne.jp>
 <20161219122738.GB427@tigerII.localdomain>
 <20161220153948.GA575@tigerII.localdomain>
 <201612221927.BGE30207.OSFJMFLFOHQtOV@I-love.SAKURA.ne.jp>
 <20161222134250.GE413@tigerII.localdomain>
 <201612222301.AFG57832.QOFMSVFOJHLOtF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="tKW2IUtsqtDRztdT"
Content-Disposition: inline
In-Reply-To: <201612222301.AFG57832.QOFMSVFOJHLOtF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: sergey.senozhatsky@gmail.com, mhocko@suse.com, linux-mm@kvack.org, pmladek@suse.cz


--tKW2IUtsqtDRztdT
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On (12/22/16 23:01), Tetsuo Handa wrote:
> > On (12/22/16 19:27), Tetsuo Handa wrote:
> > > Thank you. I tried "[PATCHv6 0/7] printk: use printk_safe to handle printk()
> > > recursive calls" at https://lkml.org/lkml/2016/12/21/232 on top of linux.git
> > > as of commit 52bce91165e5f2db "splice: reinstate SIGPIPE/EPIPE handling", but
> > > it turned out that your patch set does not solve this problem.
> > > 
> > > I was assuming that sending to consoles from printk() is offloaded to a kernel
> > > thread dedicated for that purpose, but your patch set does not do it.
> > 
> > sorry, seems that I didn't deliver the information properly.
> > 
> > https://gitlab.com/senozhatsky/linux-next-ss/commits/printk-safe-deferred
> > 
> > there are 2 patch sets. the first one is printk-safe. the second one
> > is async printk.
> > 
> > 9 patches in total (as of now).
> > 
> > can you access it?
> 
> "404 The page you're looking for could not be found."
> 
> Anonymous access not supported?

oops... hm, dunno, it says

: Visibility Level (?)
:
: Public
: The project can be cloned without any authentication.

I'll switch to github then may be.

attached 9 patches.

NOTE: not the final version.


	-ss

--tKW2IUtsqtDRztdT
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="0001-printk-use-vprintk_func-in-vprintk.patch"


--tKW2IUtsqtDRztdT--
