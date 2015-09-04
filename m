Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id A2AAC6B0255
	for <linux-mm@kvack.org>; Fri,  4 Sep 2015 16:29:41 -0400 (EDT)
Received: by pacfv12 with SMTP id fv12so34545041pac.2
        for <linux-mm@kvack.org>; Fri, 04 Sep 2015 13:29:41 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id t3si5875456pbs.179.2015.09.04.13.29.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 Sep 2015 13:29:40 -0700 (PDT)
Date: Fri, 4 Sep 2015 13:29:40 -0700
From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 2/2] android, lmk: Reverse the order of setting
 TIF_MEMDIE and sending SIGKILL.
Message-ID: <20150904202940.GA11212@kroah.com>
References: <201508262117.FAH43726.tOFMVJSLQOFHFO@I-love.SAKURA.ne.jp>
 <201508262119.IHA93770.JOOtFHMSFLOQVF@I-love.SAKURA.ne.jp>
 <20150903010620.GC31349@kroah.com>
 <20150904140559.GD8220@dhcp22.suse.cz>
 <20150904171519.GA5537@kroah.com>
 <201509050306.CDJ43754.LtFHVOMJFFOSQO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201509050306.CDJ43754.LtFHVOMJFFOSQO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: mhocko@kernel.org, arve@android.com, riandrews@android.com, devel@driverdev.osuosl.org, linux-mm@kvack.org, rientjes@google.com, hannes@cmpxchg.org

On Sat, Sep 05, 2015 at 03:06:46AM +0900, Tetsuo Handa wrote:
> Greg KH wrote:
> > On Fri, Sep 04, 2015 at 04:05:59PM +0200, Michal Hocko wrote:
> > > On Wed 02-09-15 18:06:20, Greg KH wrote:
> > > [...]
> > > > And if we aren't taking patch 1/2, I guess this one isn't needed either?
> > > 
> > > Unlike the patch1 which was pretty much cosmetic this fixes a real
> > > issue.
> > 
> > Ok, then it would be great to get this in a format that I can apply it
> > in :)
> 
> I see. Here is a minimal patch.
> (Acked-by: from http://lkml.kernel.org/r/20150827084443.GE14367@dhcp22.suse.cz )
> ----------------------------------------
> >From 118609fa25700af11791b1b7e8349f8973a9e7e4 Mon Sep 17 00:00:00 2001
> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Date: Sat, 5 Sep 2015 02:58:12 +0900
> Subject: [PATCH] android, lmk: Send SIGKILL before setting TIF_MEMDIE.
> 
> It was observed that setting TIF_MEMDIE before sending SIGKILL at
> oom_kill_process() allows memory reserves to be depleted by allocations
> which are not needed for terminating the OOM victim.
> 
> This patch reverts commit 6bc2b856bb7c ("staging: android: lowmemorykiller:
> set TIF_MEMDIE before send kill sig"), for oom_kill_process() was updated
> to send SIGKILL before setting TIF_MEMDIE.
> 
> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Acked-by: Michal Hocko <mhocko@suse.com>
> ---
>  drivers/staging/android/lowmemorykiller.c | 12 ++++--------
>  1 file changed, 4 insertions(+), 8 deletions(-)

Please send this in a format that I can apply it in that doesn't require
me to hand-edit the email :(

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
