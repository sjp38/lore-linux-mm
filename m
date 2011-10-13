Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id E02B36B002C
	for <linux-mm@kvack.org>; Thu, 13 Oct 2011 01:59:50 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 68D503EE081
	for <linux-mm@kvack.org>; Thu, 13 Oct 2011 14:59:47 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 526A745DF4A
	for <linux-mm@kvack.org>; Thu, 13 Oct 2011 14:59:47 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3CE9245DE8E
	for <linux-mm@kvack.org>; Thu, 13 Oct 2011 14:59:47 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2E1831DB8037
	for <linux-mm@kvack.org>; Thu, 13 Oct 2011 14:59:47 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id ECB001DB802F
	for <linux-mm@kvack.org>; Thu, 13 Oct 2011 14:59:46 +0900 (JST)
Date: Thu, 13 Oct 2011 14:58:51 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v6 6/8] tcp buffer limitation: per-cgroup limit
Message-Id: <20111013145851.4a3739ee.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1318242268-2234-7-git-send-email-glommer@parallels.com>
References: <1318242268-2234-1-git-send-email-glommer@parallels.com>
	<1318242268-2234-7-git-send-email-glommer@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, paul@paulmenage.org, lizf@cn.fujitsu.com, ebiederm@xmission.com, davem@davemloft.net, gthelen@google.com, netdev@vger.kernel.org, linux-mm@kvack.org, kirill@shutemov.name, avagin@parallels.com, devel@openvz.org

On Mon, 10 Oct 2011 14:24:26 +0400
Glauber Costa <glommer@parallels.com> wrote:

> This patch uses the "tcp_max_mem" field of the kmem_cgroup to
> effectively control the amount of kernel memory pinned by a cgroup.
> 
> We have to make sure that none of the memory pressure thresholds
> specified in the namespace are bigger than the current cgroup.
> 
> Signed-off-by: Glauber Costa <glommer@parallels.com>
> CC: David S. Miller <davem@davemloft.net>
> CC: Hiroyouki Kamezawa <kamezawa.hiroyu@jp.fujitsu.com>
> CC: Eric W. Biederman <ebiederm@xmission.com>

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
