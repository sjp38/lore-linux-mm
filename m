Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id EBD686B005C
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 05:59:41 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n0FAxdHX016435
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 15 Jan 2009 19:59:39 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5F18645DE5D
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 19:59:39 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3407745DE51
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 19:59:39 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id DAAF9E1800B
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 19:59:38 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 78F07E38005
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 19:59:38 +0900 (JST)
Date: Thu, 15 Jan 2009 19:58:34 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 0/4] cgroup/memcg : updates related to CSS
Message-Id: <20090115195834.e07e604d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090115105116.GG30358@balbir.in.ibm.com>
References: <20090115192120.9956911b.kamezawa.hiroyu@jp.fujitsu.com>
	<20090115105116.GG30358@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "menage@google.com" <menage@google.com>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, 15 Jan 2009 16:21:16 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-01-15 19:21:20]:
> 
> > 
> > I'm sorry that I couldn't work so much, this week.
> > No much updates but I think all comments I got are applied.
> > 
> > About memcg part, I'll wait for that all Nishimura's fixes go ahead.
> > If cgroup part looks good, please Ack. I added CC to Andrew Morton for that part.
> > 
> > changes from previous series
> >   - dropeed a fix to OOM KILL   (will reschedule)
> >   - dropped a fix to -EBUSY     (will reschedule)
> >   - added css_is_populated()
> >   - added hierarchy_stat patch
> > 
> > Known my homework is
> >   - resize_limit should return -EBUSY. (Li Zefan reported.)
> > 
> > Andrew, I'll CC: you [1/4] and [2/4]. But no explicit Acked-by yet to any patches.
> >
> 
> Kamezawa-San, like you've suggested earlier, I think it is important
> to split up the fixes from the development patches. I wonder if we
> should start marking all patches with BUGFIX for bug fixes, so that we
> can prioritize those first.
>  
Ah yes. I'll do that from next post. 

patch [1/4] and [2/4] doesnt modify memcg at all. So, I added Andrew to CC.
It's a new feature for cgroup.

for memcg part. of course, I'll wait for all Nishimura's fixes goes to -rc.

patch [3/4] will remove most of them, crazy maze of hierarchical reclaim.
patch [4/4] is written for demonstration. but the output seems atractive.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
