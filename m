Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 677769000C4
	for <linux-mm@kvack.org>; Sat, 17 Sep 2011 08:13:48 -0400 (EDT)
Message-ID: <4E748EC9.2030303@parallels.com>
Date: Sat, 17 Sep 2011 09:12:57 -0300
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 6/7] tcp buffer limitation: per-cgroup limit
References: <1316051175-17780-1-git-send-email-glommer@parallels.com> <1316051175-17780-7-git-send-email-glommer@parallels.com>
In-Reply-To: <1316051175-17780-7-git-send-email-glommer@parallels.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, paul@paulmenage.org, lizf@cn.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, ebiederm@xmission.com, davem@davemloft.net, gthelen@google.com, netdev@vger.kernel.org, linux-mm@kvack.org

On 09/14/2011 10:46 PM, Glauber Costa wrote:
> This patch uses the "tcp_max_mem" field of the kmem_cgroup to
> effectively control the amount of kernel memory pinned by a cgroup.
>
> We have to make sure that none of the memory pressure thresholds
> specified in the namespace are bigger than the current cgroup.
>
> Signed-off-by: Glauber Costa<glommer@parallels.com>
> CC: David S. Miller<davem@davemloft.net>
> CC: Hiroyouki Kamezawa<kamezawa.hiroyu@jp.fujitsu.com>
> CC: Eric W. Biederman<ebiederm@xmission.com>
> ---

heads up: I found a small problem in a corner case here yesterday.
So I will resubmit this series.

It you guys have any other comments let me know, so I can address them 
as well.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
