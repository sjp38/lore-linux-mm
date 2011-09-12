Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 907A06B0256
	for <linux-mm@kvack.org>; Mon, 12 Sep 2011 06:32:20 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 2DA023EE0AE
	for <linux-mm@kvack.org>; Mon, 12 Sep 2011 19:32:17 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 133763266C1
	for <linux-mm@kvack.org>; Mon, 12 Sep 2011 19:32:17 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id EDF6745DE58
	for <linux-mm@kvack.org>; Mon, 12 Sep 2011 19:32:16 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id DE0071DB804E
	for <linux-mm@kvack.org>; Mon, 12 Sep 2011 19:32:16 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id A47891DB8053
	for <linux-mm@kvack.org>; Mon, 12 Sep 2011 19:32:16 +0900 (JST)
Date: Mon, 12 Sep 2011 19:31:17 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v2 6/9] per-cgroup tcp buffers control
Message-Id: <20110912193117.d8f360f9.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4E6A001C.2040600@parallels.com>
References: <1315369399-3073-1-git-send-email-glommer@parallels.com>
	<1315369399-3073-7-git-send-email-glommer@parallels.com>
	<20110909121206.e1d628d1.kamezawa.hiroyu@jp.fujitsu.com>
	<4E6A001C.2040600@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, netdev@vger.kernel.org, xemul@parallels.com, "David S. Miller" <davem@davemloft.net>, "Eric W. Biederman" <ebiederm@xmission.com>

On Fri, 9 Sep 2011 09:01:32 -0300
Glauber Costa <glommer@parallels.com> wrote:

> On 09/09/2011 12:12 AM, KAMEZAWA Hiroyuki wrote:
> > On Wed,  7 Sep 2011 01:23:16 -0300
> > Glauber Costa<glommer@parallels.com>  wrote:
> >
> >> With all the infrastructure in place, this patch implements
> >> per-cgroup control for tcp memory pressure handling.
> >>
> >> Signed-off-by: Glauber Costa<glommer@parallels.com>
> >> CC: David S. Miller<davem@davemloft.net>
> >> CC: Hiroyouki Kamezawa<kamezawa.hiroyu@jp.fujitsu.com>
> >> CC: Eric W. Biederman<ebiederm@xmission.com>
> >
> > Hmm, then, kmem_cgroup.c is just a caller of plugins implemented
> > by other components ?
> 
> Kame,
> 
> Refer to my discussion with Greg. How would you feel about it being 
> accounted to a single "kernel memory" limit in memcg?
> 

Hmm, it's argued that 'cgroup is hard to use, it's difficult!!!'.

Then, if implementation is clean, I think it may be good to add
kmem limit to memcg.

Your and Greg's idea is to have

	memory.kmem_limit_in_bytes 
?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
