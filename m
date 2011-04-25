Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 644368D003B
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 08:24:13 -0400 (EDT)
Subject: Re: 2.6.39-rc4+: Kernel leaking memory during FS scanning, regression?
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <BANLkTi=2DK+iq-5NEFKexe0QhpW8G0RL8Q@mail.gmail.com>
	<20110425123444.639aad34@neptune.home>
	<20110425134145.048f7cc1@neptune.home>
	<BANLkTikpt7E5eE9vv9NFbNAwT_O6sHnQvA@mail.gmail.com>
	<201104252114.HID65107.FOHOQFMVJtOSFL@I-love.SAKURA.ne.jp>
In-Reply-To: <201104252114.HID65107.FOHOQFMVJtOSFL@I-love.SAKURA.ne.jp>
Message-Id: <201104252121.GJI30713.FMOQLFOSVFtJOH@I-love.SAKURA.ne.jp>
Date: Mon, 25 Apr 2011 21:21:51 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: penberg@kernel.org, bonbons@linux-vserver.org
Cc: vapier.adi@gmail.com, kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, catalin.marinas@arm.com, adobriyan@gmail.com, torvalds@linux-foundation.org, viro@zeniv.linux.org.uk

Tetsuo Handa wrote:
> proc_pid_make_inode() gets a ref on task, but return value of pid_revalidate()
> (one of 0, 1, -ECHILD) may not be what above 'if (pid_revalidate(dentry, NULL))'
> part expects. (-ECHILD is a new return value introduced by LOOKUP_RCU.)
Sorry, nd == NULL so never returns -ECHILD.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
