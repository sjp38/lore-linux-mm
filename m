Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id B049B6B0207
	for <linux-mm@kvack.org>; Thu,  8 Apr 2010 22:17:32 -0400 (EDT)
Date: Fri, 9 Apr 2010 11:11:45 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH] memcg: update documentation v3
Message-Id: <20100409111145.5359a872.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20100409104556.2aa6399d.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100408145800.ca90ad81.kamezawa.hiroyu@jp.fujitsu.com>
	<20100409102626.11f8b8b6.nishimura@mxp.nes.nec.co.jp>
	<20100409104556.2aa6399d.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, randy.dunlap@oracle.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Fri, 9 Apr 2010 10:45:56 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Fri, 9 Apr 2010 10:26:26 +0900
> Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> > > +Current Status: linux-2.6.34-mmotm(development version of 2010/April)
> > > +
> > > +Features:
> > > + - accounting anonymous pages, file caches, swap caches usage and limit them.
> > > + - private LRU and reclaim routine. (system's global LRU and private LRU
> > > +   work independently from each other)
> > > + - optionally, memory+swap usage can be accounted and limited.
> > > + - hierarchical accounting
> > > + - soft limit
> > > + - moving(recharging) account at moving a task is selectable.
> > > + - usage threshold notifier
> > > + - oom-killer disable knob and oom-notifier
> > > + - Root cgroup has no limit controls.
> > > +
> > > + Kernel memory and Hugepages are not under control yet. We just manage
> > > + pages on LRU. To add more controls, we have to take care of performance.
> > > +
> > > +Brief summary of control files.
> > > +
> > > + tasks				 # attach a task(thread)
> > > + cgroup.procs			 # attach a process(all threads under it)
> > IIUC, writing to cgroup.procs isn't supported yet. So, I think we don't have to
> > bother explaining cgroup.procs here.
> > 
> 
> It's supported. See Documetaion/cgroup/cgroup.txt
> IIRC, I use cgroup.procs file for migrating, sometimes.
> 
I can't write to it now.

# echo $$ >/cgroup/memory/01/cgroup.procs
-bash: echo: write error: Invalid argument
# ls -l /cgroup/memory/01/cgroup.procs
-r--r--r-- 1 root root 0 2010-04-09 10:41 /cgroup/memory/01/cgroup.procs
# uname -a
Linux GibsonE 2.6.34-rc3-mm1-00432-g37c11f5 #1 SMP Thu Apr 8 11:03:39 JST 2010 x86_64 x86_64 x86_64 GNU/Linux

And kernel/cgroup.c says:

   3161         {
   3162                 .name = CGROUP_FILE_GENERIC_PREFIX "procs",
   3163                 .open = cgroup_procs_open,
   3164                 /* .write_u64 = cgroup_procs_write, TODO */
   3165                 .release = cgroup_pidlist_release,
   3166                 .mode = S_IRUGO,
   3167         },

IIRC, it's supported once, but the patch was dropped.


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
