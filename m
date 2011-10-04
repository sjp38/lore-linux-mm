Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id F4186900117
	for <linux-mm@kvack.org>; Mon,  3 Oct 2011 21:22:07 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 8BAF83EE0B5
	for <linux-mm@kvack.org>; Tue,  4 Oct 2011 10:22:05 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 71F3045DE52
	for <linux-mm@kvack.org>; Tue,  4 Oct 2011 10:22:05 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5A6B745DE51
	for <linux-mm@kvack.org>; Tue,  4 Oct 2011 10:22:05 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 47A181DB802F
	for <linux-mm@kvack.org>; Tue,  4 Oct 2011 10:22:05 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1018C1DB8037
	for <linux-mm@kvack.org>; Tue,  4 Oct 2011 10:22:05 +0900 (JST)
Date: Tue, 4 Oct 2011 10:21:14 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v4 6/8] tcp buffer limitation: per-cgroup limit
Message-Id: <20111004102114.08b06ae8.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1317637123-18306-7-git-send-email-glommer@parallels.com>
References: <1317637123-18306-1-git-send-email-glommer@parallels.com>
	<1317637123-18306-7-git-send-email-glommer@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, paul@paulmenage.org, lizf@cn.fujitsu.com, ebiederm@xmission.com, davem@davemloft.net, gthelen@google.com, netdev@vger.kernel.org, linux-mm@kvack.org, kirill@shutemov.name, avagin@parallels.com

On Mon,  3 Oct 2011 14:18:41 +0400
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
> ---
>  Documentation/cgroups/memory.txt |    1 +
>  include/linux/memcontrol.h       |   10 +++++
>  include/net/tcp.h                |    1 +
>  mm/memcontrol.c                  |   76 +++++++++++++++++++++++++++++++++++---
>  net/ipv4/sysctl_net_ipv4.c       |   20 ++++++++++
>  5 files changed, 102 insertions(+), 6 deletions(-)
> 
> diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
> index 6f1954a..1ffde3e 100644
> --- a/Documentation/cgroups/memory.txt
> +++ b/Documentation/cgroups/memory.txt
> @@ -78,6 +78,7 @@ Brief summary of control files.
>  
>   memory.independent_kmem_limit	 # select whether or not kernel memory limits are
>  				   independent of user limits
> + memory.kmem.tcp.max_memory      # set/show hard limit for tcp buf memory
>  

What is the releationship between tcp.max_memory and kmem_limit ?

tcp.max_memory < kmem_limit ?
usage of tcp memory is included in kmem usage ?


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
