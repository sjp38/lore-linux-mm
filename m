Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id DB8DB6B005C
	for <linux-mm@kvack.org>; Thu,  8 Dec 2011 20:25:54 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id E981C3EE0BC
	for <linux-mm@kvack.org>; Fri,  9 Dec 2011 10:25:52 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id D0AB445DE83
	for <linux-mm@kvack.org>; Fri,  9 Dec 2011 10:25:52 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id B6E4F45DE84
	for <linux-mm@kvack.org>; Fri,  9 Dec 2011 10:25:52 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id A4E0B1DB804B
	for <linux-mm@kvack.org>; Fri,  9 Dec 2011 10:25:52 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 536D61DB8044
	for <linux-mm@kvack.org>; Fri,  9 Dec 2011 10:25:52 +0900 (JST)
Date: Fri, 9 Dec 2011 10:24:38 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v8 2/9] foundations of per-cgroup memory pressure
 controlling.
Message-Id: <20111209102438.2db705d0.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1323120903-2831-3-git-send-email-glommer@parallels.com>
References: <1323120903-2831-1-git-send-email-glommer@parallels.com>
	<1323120903-2831-3-git-send-email-glommer@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, lizf@cn.fujitsu.com, ebiederm@xmission.com, davem@davemloft.net, gthelen@google.com, netdev@vger.kernel.org, linux-mm@kvack.org, kirill@shutemov.name, avagin@parallels.com, devel@openvz.org, eric.dumazet@gmail.com, cgroups@vger.kernel.org, hannes@cmpxchg.org, mhocko@suse.cz

On Mon,  5 Dec 2011 19:34:56 -0200
Glauber Costa <glommer@parallels.com> wrote:

> This patch replaces all uses of struct sock fields' memory_pressure,
> memory_allocated, sockets_allocated, and sysctl_mem to acessor
> macros. Those macros can either receive a socket argument, or a mem_cgroup
> argument, depending on the context they live in.
> 
> Since we're only doing a macro wrapping here, no performance impact at all is
> expected in the case where we don't have cgroups disabled.
> 
> Signed-off-by: Glauber Costa <glommer@parallels.com>
> CC: David S. Miller <davem@davemloft.net>
> CC: Hiroyouki Kamezawa <kamezawa.hiroyu@jp.fujitsu.com>
> CC: Eric W. Biederman <ebiederm@xmission.com>
> CC: Eric Dumazet <eric.dumazet@gmail.com>

please get ack from network guys. 
from me.
Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
