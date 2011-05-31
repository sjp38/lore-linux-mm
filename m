Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id A0D716B0012
	for <linux-mm@kvack.org>; Tue, 31 May 2011 03:59:43 -0400 (EDT)
Date: Tue, 31 May 2011 03:59:38 -0400 (EDT)
From: CAI Qian <caiqian@redhat.com>
Message-ID: <348391538.318712.1306828778575.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
In-Reply-To: <4DE49F44.10809@jp.fujitsu.com>
Subject: Re: [PATCH v2 0/5] Fix oom killer doesn't work at all if system
 have > gigabytes memory  (aka CAI founded issue)
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, rientjes@google.com, hughd@google.com, kamezawa hiroyu <kamezawa.hiroyu@jp.fujitsu.com>, minchan kim <minchan.kim@gmail.com>, oleg@redhat.com



----- Original Message -----
> (2011/05/31 16:50), CAI Qian wrote:
> >
> >
> > ----- Original Message -----
> >>>> - If you run the same program as root, non root process and
> >>>> privilege
> >>>> explicit
> >>>> dropping processes (e.g. irqbalance) will be killed at first.
> >>> Hmm, at least there were some programs were root processes but
> >>> were
> >>> killed
> >>> first.
> >>> [ pid] ppid uid total_vm rss swap score_adj name
> >>> [ 5720] 5353 0 24421 257 0 0 sshd
> >>> [ 5353] 1 0 15998 189 0 0 sshd
> >>> [ 5451] 1 0 19648 235 0 0 master
> >>> [ 1626] 1 0 2287 129 0 0 dhclient
> >>
> >> Hi
> >>
> >> I can't reproduce this too. Are you sure these processes have a
> >> full
> >> root privilege?
> >> I've made new debugging patch. After applying following patch, do
> >> these processes show
> >> cap=1?
> > No, all of them had cap=0. Wondering why something like sshd not
> > been
> > made cap=1 to avoid early oom kill.
> 
> Then, I believe your distro applying distro specific patch to ssh.
> Which distro are you using now?
It is a Fedora-like distro.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
