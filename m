Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id m9O1GnRD001657
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 24 Oct 2008 10:16:49 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4719E2AC027
	for <linux-mm@kvack.org>; Fri, 24 Oct 2008 10:16:49 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1E2AE12C045
	for <linux-mm@kvack.org>; Fri, 24 Oct 2008 10:16:49 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 01B9A1DB803C
	for <linux-mm@kvack.org>; Fri, 24 Oct 2008 10:16:49 +0900 (JST)
Received: from ml12.s.css.fujitsu.com (ml12.s.css.fujitsu.com [10.249.87.102])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id B478A1DB803A
	for <linux-mm@kvack.org>; Fri, 24 Oct 2008 10:16:48 +0900 (JST)
Date: Fri, 24 Oct 2008 10:16:20 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 2/11] cgroup: make cgroup kconfig as submenu
Message-Id: <20081024101620.76170c7d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <6599ad830810231420t675fa8aalc13f7357ec876c9e@mail.gmail.com>
References: <20081023175800.73afc957.kamezawa.hiroyu@jp.fujitsu.com>
	<20081023180057.791eeba4.kamezawa.hiroyu@jp.fujitsu.com>
	<6599ad830810231420t675fa8aalc13f7357ec876c9e@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "xemul@openvz.org" <xemul@openvz.org>
List-ID: <linux-mm.kvack.org>

On Thu, 23 Oct 2008 14:20:05 -0700
"Paul Menage" <menage@google.com> wrote:

> On Thu, Oct 23, 2008 at 2:00 AM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > @@ -337,6 +284,8 @@ config GROUP_SCHED
> >        help
> >          This feature lets CPU scheduler recognize task groups and control CPU
> >          bandwidth allocation to such task groups.
> > +         For allowing to make a group from arbitrary set of processes, use
> > +         CONFIG_CGROUPS. (See Control Group support.)
> 
> Please can we make this:
> 
> In order to create a scheduler group from an arbitrary set of
> processes, use CONFIG_CGROUPS (See Control Group support).
> 
> >
> > +         This option will let you use process cgroup subsystems
> > +         such as Cpusets
> 
> This option adds support for grouping sets of processes together, for
> use with process control subsystems such as Cpusets, CFS, memory
> controls or device isolation.
> 

O.K. thank you for help.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
