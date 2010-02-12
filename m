Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id BB4D26B0047
	for <linux-mm@kvack.org>; Thu, 11 Feb 2010 21:45:11 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o1C2j9Dr013232
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 12 Feb 2010 11:45:09 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id E0AC645DE56
	for <linux-mm@kvack.org>; Fri, 12 Feb 2010 11:45:08 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id EDDD745DE57
	for <linux-mm@kvack.org>; Fri, 12 Feb 2010 11:45:05 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id B4C621DB8041
	for <linux-mm@kvack.org>; Fri, 12 Feb 2010 11:45:05 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 78B86E08002
	for <linux-mm@kvack.org>; Fri, 12 Feb 2010 11:45:00 +0900 (JST)
Date: Fri, 12 Feb 2010 11:41:33 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [BUGFIX][PATCH] memcg: fix oom killing a child process in an
 other cgroup
Message-Id: <20100212114133.57bb1141.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <28c262361002111839t291b8ac2xdb9b89b354a115e0@mail.gmail.com>
References: <20100212105318.caf37133.kamezawa.hiroyu@jp.fujitsu.com>
	<28c262361002111839t291b8ac2xdb9b89b354a115e0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, stable@kernel.org, rientjes@google.com, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Fri, 12 Feb 2010 11:39:35 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> On Fri, Feb 12, 2010 at 10:53 AM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > This patch itself is againt mmotm-Feb10 but can be applied to 2.6.32.8
> > without problem.
> >
> > ==
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> >
> > Now, oom-killer is memcg aware and it finds the worst process from
> > processes under memcg(s) in oom. Then, it kills victim's child at first.
> > It may kill a child in other cgroup and may not be any help for recovery.
> > And it will break the assumption users have...
> >
> > This patch fixes it.
> >
> > CC: stable@kernel.org
> > CC: Minchan Kim <minchan.kim@gmail.com>
> > CC: Balbir Singh <balbir@linux.vnet.ibm.com>
> > CC: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> > Acked-by: David Rientjes <rientjes@google.com>
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
> 
> Sorry for noise, Kame.
> 
No problem. You give me a chance to consider other problems/dirtiness of codes.
I continue review to make memcg cleaer.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
