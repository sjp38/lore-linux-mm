Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 3EB626B0088
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 07:54:14 -0500 (EST)
Received: by yxm34 with SMTP id 34so4622721yxm.14
        for <linux-mm@kvack.org>; Tue, 09 Nov 2010 04:54:12 -0800 (PST)
From: Ben Gamari <bgamari.foss@gmail.com>
Subject: Re: fadvise DONTNEED implementation (or lack thereof)
In-Reply-To: <20101109162525.BC87.A69D9226@jp.fujitsu.com>
References: <87lj597hp9.fsf@gmail.com> <20101109162525.BC87.A69D9226@jp.fujitsu.com>
Date: Tue, 09 Nov 2010 07:54:07 -0500
Message-ID: <877hgmr72o.fsf@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, rsync@lists.samba.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue,  9 Nov 2010 16:28:02 +0900 (JST), KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> So, I don't think application developers will use fadvise() aggressively
> because we don't have a cross platform agreement of a fadvice behavior.
> 
I strongly disagree. For a long time I have been trying to resolve
interactivity issues caused by my rsync-based backup script. Many kernel
developers have said that there is nothing the kernel can do without
more information from user-space (e.g. cgroups, madvise). While cgroups
help, the fix is round-about at best and requires configuration where
really none should be necessary. The easiest solution for everyone
involved would be for rsync to use FADV_DONTNEED. The behavior doesn't
need to be perfectly consistent between platforms for the flag to be
useful so long as each implementation does something sane to help
use-once access patterns.

People seem to mention frequently that there are no users of
FADV_DONTNEED and therefore we don't need to implement it. It seems like
this is ignoring an obvious catch-22. Currently rsync has no fadvise
support at all, since using[1] the implemented hints to get the desired
effect is far too complicated^M^M^M^Mhacky to be considered
merge-worthy. Considering the number of Google hits returned for
fadvise, I wouldn't be surprised if there were countless other projects
with this same difficulty. We want to be able to tell the kernel about
our useage patterns, but the kernel won't listen.

Cheers,

- Ben

[1] http://insights.oetiker.ch/linux/fadvise.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
