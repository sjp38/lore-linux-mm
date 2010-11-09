Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id C17436B004A
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 16:06:51 -0500 (EST)
Received: from hpaq2.eem.corp.google.com (hpaq2.eem.corp.google.com [172.25.149.2])
	by smtp-out.google.com with ESMTP id oA9L6lEv008333
	for <linux-mm@kvack.org>; Tue, 9 Nov 2010 13:06:47 -0800
Received: from pzk36 (pzk36.prod.google.com [10.243.19.164])
	by hpaq2.eem.corp.google.com with ESMTP id oA9L6j4e021821
	for <linux-mm@kvack.org>; Tue, 9 Nov 2010 13:06:46 -0800
Received: by pzk36 with SMTP id 36so1930304pzk.2
        for <linux-mm@kvack.org>; Tue, 09 Nov 2010 13:06:45 -0800 (PST)
Date: Tue, 9 Nov 2010 13:06:42 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2]oom-kill: CAP_SYS_RESOURCE should get bonus
In-Reply-To: <20101109122437.2e0d71fd@lxorguk.ukuu.org.uk>
Message-ID: <alpine.DEB.2.00.1011091300510.7730@chino.kir.corp.google.com>
References: <1288834737.2124.11.camel@myhost> <alpine.DEB.2.00.1011031847450.21550@chino.kir.corp.google.com> <20101109195726.BC9E.A69D9226@jp.fujitsu.com> <20101109122437.2e0d71fd@lxorguk.ukuu.org.uk>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Figo.zhang" <zhangtianfei@leadcoretech.com>, figo zhang <figo1802@gmail.com>, lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

On Tue, 9 Nov 2010, Alan Cox wrote:

> The reverse can be argued equally - that they can unprotect themselves if
> necessary. In fact it seems to be a "point of view" sort of question
> which way you deal with CAP_SYS_RESOURCE, and that to me argues that
> changing from old expected behaviour to a new behaviour is a regression.
> 

I didn't check earlier, but CAP_SYS_RESOURCE hasn't had a place in the oom 
killer's heuristic in over five years, so what regression are we referring 
to in this thread?  These tasks already have full control over 
oom_score_adj to modify its oom killing priority in either direction.

And, as I said, giving these threads a bonus to be less preferred doesn't 
seem appropriate since (1) it's not a defined or expected behavior of 
CAP_SYS_RESOURCE like it is for sysadmin tasks, and (2) these threads are 
not bound by resource limits and thus have a higher liklihood of consuming 
larger amounts of memory.

That's why I nack'd the patch in the first place and still do, there's no 
regression here and it's not in the best interest of freeing a large 
amount of memory which is the sole purpose of the oom killer.

Futhermore, the heuristic was entirely rewritten, but I wouldn't consider 
all the old factors such as cputime and nice level being removed as 
"regressions" since the aim was to make it more predictable and more 
likely to kill a large consumer of memory such that we don't have to kill 
more tasks in the near future.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
