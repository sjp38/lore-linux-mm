Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f174.google.com (mail-ig0-f174.google.com [209.85.213.174])
	by kanga.kvack.org (Postfix) with ESMTP id 0EFE96B0254
	for <linux-mm@kvack.org>; Wed,  2 Sep 2015 21:06:22 -0400 (EDT)
Received: by igbni9 with SMTP id ni9so28139857igb.0
        for <linux-mm@kvack.org>; Wed, 02 Sep 2015 18:06:21 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id vk4si3858025igb.97.2015.09.02.18.06.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Sep 2015 18:06:21 -0700 (PDT)
Date: Wed, 2 Sep 2015 18:06:20 -0700
From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 2/2] android, lmk: Reverse the order of setting
 TIF_MEMDIE and sending SIGKILL.
Message-ID: <20150903010620.GC31349@kroah.com>
References: <201508262117.FAH43726.tOFMVJSLQOFHFO@I-love.SAKURA.ne.jp>
 <201508262119.IHA93770.JOOtFHMSFLOQVF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201508262119.IHA93770.JOOtFHMSFLOQVF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: arve@android.com, riandrews@android.com, devel@driverdev.osuosl.org, linux-mm@kvack.org, mhocko@kernel.org, rientjes@google.com, hannes@cmpxchg.org

On Wed, Aug 26, 2015 at 09:19:48PM +0900, Tetsuo Handa wrote:
> Hello.
> 
> Should selected_tasksize be added to rem even when TIF_MEMDIE was not set?
> 
> Please see a thread from http://www.spinics.net/lists/linux-mm/msg93246.html
> if you want to know why to reverse the order.
> ----------------------------------------
> >From 2d4cc11d8128e4c1397631b91fea78da3eaefb47 Mon Sep 17 00:00:00 2001
> From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Date: Wed, 26 Aug 2015 20:52:39 +0900
> Subject: [PATCH 2/2] android, lmk: Reverse the order of setting TIF_MEMDIE and sending SIGKILL.
> 
> If we set TIF_MEMDIE before sending SIGKILL, memory reserves could be
> spent for allocations which are not needed for terminating the victim.
> Reverse the order as with oom_kill_process() does.


I can't take a patch that I have to hand-edit in order to apply it :(

And if we aren't taking patch 1/2, I guess this one isn't needed either?

thanks,

greg k-h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
