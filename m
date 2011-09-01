Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id A90E56B016A
	for <linux-mm@kvack.org>; Wed, 31 Aug 2011 20:09:53 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id EB6363EE0AE
	for <linux-mm@kvack.org>; Thu,  1 Sep 2011 09:09:48 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id CE66645DE5D
	for <linux-mm@kvack.org>; Thu,  1 Sep 2011 09:09:48 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id B524B45DE59
	for <linux-mm@kvack.org>; Thu,  1 Sep 2011 09:09:48 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id A2DAC1DB8054
	for <linux-mm@kvack.org>; Thu,  1 Sep 2011 09:09:48 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 68B7E1DB804F
	for <linux-mm@kvack.org>; Thu,  1 Sep 2011 09:09:48 +0900 (JST)
Date: Thu, 1 Sep 2011 09:02:19 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] Enable OOM when moving processes between cgroups?
Message-Id: <20110901090219.187777ab.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110831175422.GB21571@redhat.com>
References: <1314811941-14587-1-git-send-email-viktor.rosendahl@nokia.com>
	<20110831175422.GB21571@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <jweiner@redhat.com>
Cc: Viktor Rosendahl <viktor.rosendahl@nokia.com>, linux-mm@kvack.org, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Michal Hocko <mhocko@suse.cz>

On Wed, 31 Aug 2011 19:54:22 +0200
Johannes Weiner <jweiner@redhat.com> wrote:

> On Wed, Aug 31, 2011 at 08:32:21PM +0300, Viktor Rosendahl wrote:
> > Hello,
> > 
> > I wonder if there is a specific reason why the  OOM killer hasn't been enabled
> > in the mem_cgroup_do_precharge() function in mm/memcontrol.c ?
> > 
> > In my testing (2.6.32 kernel with some backported cgroups patches), it improves
> > the case when there isn't room for the task in the target cgroup.
> 
> Tasks are moved directly on behalf of a request from userspace.  We
> would much prefer denying that single request than invoking the
> oom-killer on the whole group.
> 
Yes, I agree.

> Quite a lot changed in the trycharge-reclaim-retry path since 2009.
> Nowadays, charging is retried as long as reclaim is making any
> progress at all, so I don't see that it would give up moving a task
> too lightly, even without the extra OOM looping.
> 
> Is there any chance you could retry with a more recent kernel?
> 

It's curious topic.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
