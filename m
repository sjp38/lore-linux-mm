Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id AF5AE9000DF
	for <linux-mm@kvack.org>; Mon,  3 Oct 2011 20:42:38 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id D12C43EE0C1
	for <linux-mm@kvack.org>; Tue,  4 Oct 2011 09:42:33 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id AE77845DE81
	for <linux-mm@kvack.org>; Tue,  4 Oct 2011 09:42:33 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8224645DE68
	for <linux-mm@kvack.org>; Tue,  4 Oct 2011 09:42:33 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 740C51DB8038
	for <linux-mm@kvack.org>; Tue,  4 Oct 2011 09:42:33 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 3DB781DB803F
	for <linux-mm@kvack.org>; Tue,  4 Oct 2011 09:42:33 +0900 (JST)
Date: Tue, 4 Oct 2011 09:41:40 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v4 2/8] socket: initial cgroup code.
Message-Id: <20111004094140.2f7c34e7.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1317637123-18306-3-git-send-email-glommer@parallels.com>
References: <1317637123-18306-1-git-send-email-glommer@parallels.com>
	<1317637123-18306-3-git-send-email-glommer@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, paul@paulmenage.org, lizf@cn.fujitsu.com, ebiederm@xmission.com, davem@davemloft.net, gthelen@google.com, netdev@vger.kernel.org, linux-mm@kvack.org, kirill@shutemov.name, avagin@parallels.com

On Mon,  3 Oct 2011 14:18:37 +0400
Glauber Costa <glommer@parallels.com> wrote:

> We aim to control the amount of kernel memory pinned at any
> time by tcp sockets. To lay the foundations for this work,
> this patch adds a pointer to the kmem_cgroup to the socket
> structure.
> 
> Signed-off-by: Glauber Costa <glommer@parallels.com>
> CC: David S. Miller <davem@davemloft.net>
> CC: Hiroyouki Kamezawa <kamezawa.hiroyu@jp.fujitsu.com>
> CC: Eric W. Biederman <ebiederm@xmission.com>

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujtsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
