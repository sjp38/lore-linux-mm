Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 574906B0024
	for <linux-mm@kvack.org>; Mon,  2 May 2011 11:46:33 -0400 (EDT)
Date: Mon, 2 May 2011 08:46:30 -0700
From: Randy Dunlap <rdunlap@xenotime.net>
Subject: Re: mmotm 2011-04-29-16-25 uploaded
Message-Id: <20110502084630.82f7e7c6.rdunlap@xenotime.net>
In-Reply-To: <20110501164918.75E0.A69D9226@jp.fujitsu.com>
References: <201104300002.p3U02Ma2026266@imap1.linux-foundation.org>
	<20110430094616.1fd43735.rdunlap@xenotime.net>
	<20110501164918.75E0.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Sun,  1 May 2011 16:47:43 +0900 (JST) KOSAKI Motohiro wrote:

> > On Fri, 29 Apr 2011 16:26:16 -0700 akpm@linux-foundation.org wrote:
> > 
> > > The mm-of-the-moment snapshot 2011-04-29-16-25 has been uploaded to
> > > 
> > >    http://userweb.kernel.org/~akpm/mmotm/
> > > 
> > > and will soon be available at
> > > 
> > >    git://zen-kernel.org/kernel/mmotm.git
> > > 
> > > It contains the following patches against 2.6.39-rc5:
> > 
> > 
> > mm-per-node-vmstat-show-proper-vmstats.patch
> > 
> > when CONFIG_PROC_FS is not enabled:
> > 
> > drivers/built-in.o: In function `node_read_vmstat':
> > node.c:(.text+0x1e995): undefined reference to `vmstat_text'
> > 
> > from drivers/base/node.c
> 
> 
> Thank you for finding that!
> 
> 
> 
> From 63ad7c06f082f8423c033b9f54070e14d561db7e Mon Sep 17 00:00:00 2001
> From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Date: Sun, 1 May 2011 16:00:09 +0900
> Subject: [PATCH] vmstat: fix build error when SYSFS=y and PROC_FS=n
> 
> Randy Dunlap pointed out node.c makes build error when
> PROC_FS=n. Because node.c#node_read_vmstat() uses vmstat_text
> and it depend on PROC_FS.
> 
> Thus, this patch change it to depend both SYSFS and PROC_FS.
> 
> Reported-by: Randy Dunlap <rdunlap@xenotime.net>

Acked-by: Randy Dunlap <rdunlap@xenotime.net>

Thanks.

> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> ---
>  mm/vmstat.c |  261 ++++++++++++++++++++++++++++++-----------------------------
>  1 files changed, 132 insertions(+), 129 deletions(-)


---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
