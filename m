Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 5FDB06B0047
	for <linux-mm@kvack.org>; Thu,  1 Dec 2011 17:35:37 -0500 (EST)
Received: by iapp10 with SMTP id p10so562057iap.14
        for <linux-mm@kvack.org>; Thu, 01 Dec 2011 14:35:34 -0800 (PST)
Date: Thu, 1 Dec 2011 14:35:31 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [3.2-rc3] OOM killer doesn't kill the obvious memory hog
In-Reply-To: <20111201124634.GY7046@dastard>
Message-ID: <alpine.DEB.2.00.1112011432110.27778@chino.kir.corp.google.com>
References: <20111201093644.GW7046@dastard> <20111201185001.5bf85500.kamezawa.hiroyu@jp.fujitsu.com> <20111201124634.GY7046@dastard>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 1 Dec 2011, Dave Chinner wrote:

> > /*
> >  * /proc/<pid>/oom_score_adj set to OOM_SCORE_ADJ_MIN disables oom killing for
> >  * pid.
> >  */
> > #define OOM_SCORE_ADJ_MIN       (-1000)
> > 
> >  
> > IIUC, this task cannot be killed by oom-killer because of oom_score_adj settings.
> 
> It's not me or the test suite that setting this, so it's something
> the kernel must be doing automagically.
> 

The kernel does not set oom_score_adj to ever disable oom killing for a 
thread.  The only time the kernel touches oom_score_adj is when setting it 
to "1000" in ksm and swap to actually prefer a memory allocator for oom 
killing.

It's also possible to change this value via the deprecated 
/proc/pid/oom_adj interface until it is removed next year.  Check your 
dmesg for warnings about using the deprecated oom_adj interface or change 
the printk_once() in oom_adjust_write() to a normal printk() to catch it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
