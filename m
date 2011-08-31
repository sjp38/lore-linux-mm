Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id C11DB6B00EE
	for <linux-mm@kvack.org>; Wed, 31 Aug 2011 13:54:28 -0400 (EDT)
Date: Wed, 31 Aug 2011 19:54:22 +0200
From: Johannes Weiner <jweiner@redhat.com>
Subject: Re: [PATCH] Enable OOM when moving processes between cgroups?
Message-ID: <20110831175422.GB21571@redhat.com>
References: <1314811941-14587-1-git-send-email-viktor.rosendahl@nokia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1314811941-14587-1-git-send-email-viktor.rosendahl@nokia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Viktor Rosendahl <viktor.rosendahl@nokia.com>
Cc: linux-mm@kvack.org, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>

On Wed, Aug 31, 2011 at 08:32:21PM +0300, Viktor Rosendahl wrote:
> Hello,
> 
> I wonder if there is a specific reason why the  OOM killer hasn't been enabled
> in the mem_cgroup_do_precharge() function in mm/memcontrol.c ?
> 
> In my testing (2.6.32 kernel with some backported cgroups patches), it improves
> the case when there isn't room for the task in the target cgroup.

Tasks are moved directly on behalf of a request from userspace.  We
would much prefer denying that single request than invoking the
oom-killer on the whole group.

Quite a lot changed in the trycharge-reclaim-retry path since 2009.
Nowadays, charging is retried as long as reclaim is making any
progress at all, so I don't see that it would give up moving a task
too lightly, even without the extra OOM looping.

Is there any chance you could retry with a more recent kernel?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
