Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id EFDED900117
	for <linux-mm@kvack.org>; Mon,  3 Oct 2011 21:17:27 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 467423EE0C1
	for <linux-mm@kvack.org>; Tue,  4 Oct 2011 10:17:25 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2D16C45DE54
	for <linux-mm@kvack.org>; Tue,  4 Oct 2011 10:17:25 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 134B245DE51
	for <linux-mm@kvack.org>; Tue,  4 Oct 2011 10:17:25 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id F34671DB803E
	for <linux-mm@kvack.org>; Tue,  4 Oct 2011 10:17:24 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id BCCFF1DB803F
	for <linux-mm@kvack.org>; Tue,  4 Oct 2011 10:17:24 +0900 (JST)
Date: Tue, 4 Oct 2011 10:16:33 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v4 4/8] per-cgroup tcp buffers control
Message-Id: <20111004101633.6b44201d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1317637123-18306-5-git-send-email-glommer@parallels.com>
References: <1317637123-18306-1-git-send-email-glommer@parallels.com>
	<1317637123-18306-5-git-send-email-glommer@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, paul@paulmenage.org, lizf@cn.fujitsu.com, ebiederm@xmission.com, davem@davemloft.net, gthelen@google.com, netdev@vger.kernel.org, linux-mm@kvack.org, kirill@shutemov.name, avagin@parallels.com

On Mon,  3 Oct 2011 14:18:39 +0400
Glauber Costa <glommer@parallels.com> wrote:

> With all the infrastructure in place, this patch implements
> per-cgroup control for tcp memory pressure handling.
> 
> Signed-off-by: Glauber Costa <glommer@parallels.com>
> CC: David S. Miller <davem@davemloft.net>
> CC: Hiroyouki Kamezawa <kamezawa.hiroyu@jp.fujitsu.com>
> CC: Eric W. Biederman <ebiederm@xmission.com>

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujtisu.com>

One question.
> +void tcp_enter_memory_pressure(struct sock *sk)
> +{
> +	struct mem_cgroup *memcg = sk->sk_cgrp;
> +	if (!memcg->tcp.tcp_memory_pressure) {
> +		NET_INC_STATS(sock_net(sk), LINUX_MIB_TCPMEMORYPRESSURES);
> +		memcg->tcp.tcp_memory_pressure = 1;
> +	}
> +}

It seems memcg->tcp.tcp_memory_pressure has no locks and not atomic.

no problematic race ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
