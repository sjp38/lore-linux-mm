Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 767F16B025F
	for <linux-mm@kvack.org>; Wed, 26 Jul 2017 17:31:56 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id c184so16930803wmd.6
        for <linux-mm@kvack.org>; Wed, 26 Jul 2017 14:31:56 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id k88si9986204wmh.170.2017.07.26.14.31.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Jul 2017 14:31:55 -0700 (PDT)
Date: Wed, 26 Jul 2017 14:31:53 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] swap: fix oops during block io poll in swapin path
Message-Id: <20170726143153.4b74dad79efb13480c728c04@linux-foundation.org>
In-Reply-To: <20170726163349.GA51657@MacBook-Pro.dhcp.thefacebook.com>
References: <1501064703-5888-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20170726163349.GA51657@MacBook-Pro.dhcp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@fb.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Tim Chen <tim.c.chen@intel.com>, Huang Ying <ying.huang@intel.com>, Jens Axboe <axboe@fb.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org

On Wed, 26 Jul 2017 09:33:50 -0700 Shaohua Li <shli@fb.com> wrote:

> On Wed, Jul 26, 2017 at 07:25:03PM +0900, Tetsuo Handa wrote:
> > When a thread is OOM-killed during swap_readpage() operation, an oops
> > occurs because end_swap_bio_read() is calling wake_up_process() based on
> > an assumption that the thread which called swap_readpage() is still alive.
> > 
>
> ...
>
> > 
> > Fix it by holding a reference to the thread.
> 
> Ok, so the task is killed in the page fault retry time check, thanks!
> 
> Reviewed-by: Shaohua Li <shli@fb.com>
> 

The original patch didn't appear in my inbox and marc.info doesn't
appear to have received it either.    Can we please have a resend?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
