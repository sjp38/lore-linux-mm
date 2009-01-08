Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id C10D46B0044
	for <linux-mm@kvack.org>; Wed,  7 Jan 2009 23:46:09 -0500 (EST)
Date: Thu, 8 Jan 2009 13:41:33 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [RFC][PATCH 0/4] Memory controller soft limit patches
Message-Id: <20090108134133.6edf461f.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20090108035930.GB7294@balbir.in.ibm.com>
References: <20090107184110.18062.41459.sendpatchset@localhost.localdomain>
	<20090108093040.22d5f281.kamezawa.hiroyu@jp.fujitsu.com>
	<20090108035930.GB7294@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: nishimura@mxp.nes.nec.co.jp, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, riel@redhat.com, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

> >   1. please fix current bugs on hierarchy management, before new feature.
> >      AFAIK, OOM-Kill under hierarchy is broken. (I have patches but waits for
> >      merge window close.)
> 
> I've not hit the OOM-kill issue under hierarchy so far, is the OOM
> killer selecting a bad task to kill? I'll debug/reproduce the issue.
> I am not posting these patches for inclusion, fixing bugs is
> definitely the highest priority.
> 
I agree.

Just FYI, I have several bug fix patches for current memcg(that is for .29).
I've been testing them now, and it survives my test(rmdir aftre task move
under memory pressure and page migration) w/o big problem(except oom) for hours
in both use_hierarchy==0/1 case.

> >      I wonder there will be some others. Lockdep error which Nishimura reported
> >      are all fixed now ?
> 
> I run all my kernels and tests with lockdep enabled, I did not see any
> lockdep errors showing up.
> 
I think Paul's hierarchy_mutex patches fixed the dead lock, I haven't seen
the dead lock after the patch.
(Although, it may cause another dead lock when other subsystems are added.)


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
