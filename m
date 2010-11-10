Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 88F356B004A
	for <linux-mm@kvack.org>; Wed, 10 Nov 2010 09:46:00 -0500 (EST)
Received: by bwz16 with SMTP id 16so854287bwz.14
        for <linux-mm@kvack.org>; Wed, 10 Nov 2010 06:45:58 -0800 (PST)
Subject: Re: [PATCH v2]oom-kill: CAP_SYS_RESOURCE should get bonus
From: "Figo.zhang" <figo1802@gmail.com>
In-Reply-To: <alpine.DEB.2.00.1011091300510.7730@chino.kir.corp.google.com>
References: <1288834737.2124.11.camel@myhost>
	 <alpine.DEB.2.00.1011031847450.21550@chino.kir.corp.google.com>
	 <20101109195726.BC9E.A69D9226@jp.fujitsu.com>
	 <20101109122437.2e0d71fd@lxorguk.ukuu.org.uk>
	 <alpine.DEB.2.00.1011091300510.7730@chino.kir.corp.google.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 10 Nov 2010 22:38:11 +0800
Message-ID: <1289399891.10699.14.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Figo.zhang" <zhangtianfei@leadcoretech.com>, lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2010-11-09 at 13:06 -0800, David Rientjes wrote:
> On Tue, 9 Nov 2010, Alan Cox wrote:
> 
> > The reverse can be argued equally - that they can unprotect themselves if
> > necessary. In fact it seems to be a "point of view" sort of question
> > which way you deal with CAP_SYS_RESOURCE, and that to me argues that
> > changing from old expected behaviour to a new behaviour is a regression.
> > 
> 
> I didn't check earlier, but CAP_SYS_RESOURCE hasn't had a place in the oom 
> killer's heuristic in over five years, so what regression are we referring 
> to in this thread?  These tasks already have full control over 
> oom_score_adj to modify its oom killing priority in either direction.

yes, it can control by user, but is it all system administrators will
adjust all of the processes by each one and one in real word? suppose if
it has thousands of processes in database system.

> Futhermore, the heuristic was entirely rewritten, but I wouldn't consider 
> all the old factors such as cputime and nice level being removed as 
> "regressions" since the aim was to make it more predictable and more 
> likely to kill a large consumer of memory such that we don't have to kill 
> more tasks in the near future.

the goal of oom_killer is to find out the best process to kill, the one
should be:
1. it is a most memory comsuming process in all processes
2. and it was a proper process to kill, which will not be let system 
into unpredictable state as possible.

if a user process and a process such email cleint "evolution" with
ditecly hareware access such as "Xorg", they have eat the equal memory,
so which process are you want to kill?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
