Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 0D31C600370
	for <linux-mm@kvack.org>; Thu,  8 Apr 2010 23:04:55 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3934rud017534
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 9 Apr 2010 12:04:53 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2476645DE79
	for <linux-mm@kvack.org>; Fri,  9 Apr 2010 12:04:53 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id E213A45DE6E
	for <linux-mm@kvack.org>; Fri,  9 Apr 2010 12:04:52 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id CBE291DB8043
	for <linux-mm@kvack.org>; Fri,  9 Apr 2010 12:04:52 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6DE6F1DB803A
	for <linux-mm@kvack.org>; Fri,  9 Apr 2010 12:04:52 +0900 (JST)
Date: Fri, 9 Apr 2010 12:01:04 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] memcg: update documentation v3
Message-Id: <20100409120104.9db5b88c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100409111145.5359a872.nishimura@mxp.nes.nec.co.jp>
References: <20100408145800.ca90ad81.kamezawa.hiroyu@jp.fujitsu.com>
	<20100409102626.11f8b8b6.nishimura@mxp.nes.nec.co.jp>
	<20100409104556.2aa6399d.kamezawa.hiroyu@jp.fujitsu.com>
	<20100409111145.5359a872.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, randy.dunlap@oracle.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, 9 Apr 2010 11:11:45 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> On Fri, 9 Apr 2010 10:45:56 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Fri, 9 Apr 2010 10:26:26 +0900
> > Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> > > > +Current Status: linux-2.6.34-mmotm(development version of 2010/April)
> > > > +
> > > > +Features:
> > > > + - accounting anonymous pages, file caches, swap caches usage and limit them.
> > > > + - private LRU and reclaim routine. (system's global LRU and private LRU
> > > > +   work independently from each other)
> > > > + - optionally, memory+swap usage can be accounted and limited.
> > > > + - hierarchical accounting
> > > > + - soft limit
> > > > + - moving(recharging) account at moving a task is selectable.
> > > > + - usage threshold notifier
> > > > + - oom-killer disable knob and oom-notifier
> > > > + - Root cgroup has no limit controls.
> > > > +
> > > > + Kernel memory and Hugepages are not under control yet. We just manage
> > > > + pages on LRU. To add more controls, we have to take care of performance.
> > > > +
> > > > +Brief summary of control files.
> > > > +
> > > > + tasks				 # attach a task(thread)
> > > > + cgroup.procs			 # attach a process(all threads under it)
> > > IIUC, writing to cgroup.procs isn't supported yet. So, I think we don't have to
> > > bother explaining cgroup.procs here.
> > > 
> > 
> > It's supported. See Documetaion/cgroup/cgroup.txt
> > IIRC, I use cgroup.procs file for migrating, sometimes.
> > 
> I can't write to it now.
> 
> # echo $$ >/cgroup/memory/01/cgroup.procs
> -bash: echo: write error: Invalid argument
> # ls -l /cgroup/memory/01/cgroup.procs
> -r--r--r-- 1 root root 0 2010-04-09 10:41 /cgroup/memory/01/cgroup.procs
> # uname -a
> Linux GibsonE 2.6.34-rc3-mm1-00432-g37c11f5 #1 SMP Thu Apr 8 11:03:39 JST 2010 x86_64 x86_64 x86_64 GNU/Linux
> 
> And kernel/cgroup.c says:
> 
>    3161         {
>    3162                 .name = CGROUP_FILE_GENERIC_PREFIX "procs",
>    3163                 .open = cgroup_procs_open,
>    3164                 /* .write_u64 = cgroup_procs_write, TODO */
>    3165                 .release = cgroup_pidlist_release,
>    3166                 .mode = S_IRUGO,
>    3167         },
> 
> IIRC, it's supported once, but the patch was dropped.
> 
Ouch....I have to fix (our internal) user manual, too.....


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
