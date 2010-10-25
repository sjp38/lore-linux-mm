Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 3C3116B008A
	for <linux-mm@kvack.org>; Sun, 24 Oct 2010 20:18:38 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9P0IYTV030328
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 25 Oct 2010 09:18:34 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id F0F4945DE4F
	for <linux-mm@kvack.org>; Mon, 25 Oct 2010 09:18:33 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id D38E045DD75
	for <linux-mm@kvack.org>; Mon, 25 Oct 2010 09:18:33 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id B1F26E08002
	for <linux-mm@kvack.org>; Mon, 25 Oct 2010 09:18:33 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 64C25E08001
	for <linux-mm@kvack.org>; Mon, 25 Oct 2010 09:18:33 +0900 (JST)
Date: Mon, 25 Oct 2010 09:13:04 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH V3] nommu: add anonymous page memcg accounting
Message-Id: <20101025091304.871c8a50.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1287753968.2589.58.camel@iscandar.digidescorp.com>
References: <1287664088-4483-1-git-send-email-steve@digidescorp.com>
	<20101022122010.793bebac.kamezawa.hiroyu@jp.fujitsu.com>
	<1287753968.2589.58.camel@iscandar.digidescorp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: steve@digidescorp.com
Cc: linux-mm@kvack.org, balbir@linux.vnet.ibm.com, dhowells@redhat.com, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, 22 Oct 2010 08:26:08 -0500
"Steven J. Magnani" <steve@digidescorp.com> wrote:

> On Fri, 2010-10-22 at 12:20 +0900, KAMEZAWA Hiroyuki wrote:
> > BTW, have you tried oom_notifier+NOMMU memory limit oom-killer ?
> > It may be a chance to implement a custom OOM-Killer in userland on
> > EMBEDED systems.
> 
> No - for what I need (simple sandboxing) just running my 'problem'
> process in a memory cgroup is sufficient. I might even be able to get
> away with oom_kill_allocating_task and no cgroup, but since that would
> allow dosfsck to run the system completely out of memory there's no
> guarantee that it would be the one that pushes the system over the edge.
> 
> What do you mean by "NOMMU memory limit"? (Is there some other way to
> achieve the same functionality?)
> 

I just meant memory cgroup for NOMMU.

> I looked into David's initial suggestion of using ulimit to create a
> sandbox but it seems that nommu.c doesn't respect RLIMIT_AS. When I can
> find some time I'll try to cook up a patch for that.

Hmm. I think fixing RLIMIT_AS is better. (but no nack to this patch.)
Using memcg for _a_ program sounds like overkill...

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
