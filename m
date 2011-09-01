Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 6AABE6B016A
	for <linux-mm@kvack.org>; Wed, 31 Aug 2011 20:28:47 -0400 (EDT)
Date: Thu, 1 Sep 2011 09:13:41 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH] Enable OOM when moving processes between cgroups?
Message-Id: <20110901091341.08174b77.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20110831175422.GB21571@redhat.com>
References: <1314811941-14587-1-git-send-email-viktor.rosendahl@nokia.com>
	<20110831175422.GB21571@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Viktor Rosendahl <viktor.rosendahl@nokia.com>
Cc: linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <jweiner@redhat.com>, Michal Hocko <mhocko@suse.cz>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

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
I agree. OOM is disabled intentionally at the path.

Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
