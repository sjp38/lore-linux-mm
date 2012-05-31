Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 410916B005C
	for <linux-mm@kvack.org>; Wed, 30 May 2012 20:11:07 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 60FEB3EE0B6
	for <linux-mm@kvack.org>; Thu, 31 May 2012 09:11:05 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4B39045DE4E
	for <linux-mm@kvack.org>; Thu, 31 May 2012 09:11:05 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 20F1F45DE56
	for <linux-mm@kvack.org>; Thu, 31 May 2012 09:11:05 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 131441DB803C
	for <linux-mm@kvack.org>; Thu, 31 May 2012 09:11:05 +0900 (JST)
Received: from m1000.s.css.fujitsu.com (m1000.s.css.fujitsu.com [10.240.81.136])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id BBB5A1DB8038
	for <linux-mm@kvack.org>; Thu, 31 May 2012 09:11:04 +0900 (JST)
Message-ID: <4FC6B68C.2070703@jp.fujitsu.com>
Date: Thu, 31 May 2012 09:08:44 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] meminfo: show /proc/meminfo base on container's memcg
References: <1338260214-21919-1-git-send-email-gaofeng@cn.fujitsu.com> <alpine.DEB.2.00.1205301433490.9716@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1205301433490.9716@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Gao feng <gaofeng@cn.fujitsu.com>, hannes@cmpxchg.org, mhocko@suse.cz, bsingharora@gmail.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, containers@lists.linux-foundation.org

(2012/05/31 6:38), David Rientjes wrote:
> On Tue, 29 May 2012, Gao feng wrote:
>
>> cgroup and namespaces are used for creating containers but some of
>> information is not isolated/virtualized. This patch is for isolating /proc/meminfo
>> information per container, which uses memory cgroup. By this, top,free
>> and other tools under container can work as expected(show container's
>> usage) without changes.
>>
>> This patch is a trial to show memcg's info in /proc/meminfo if 'current'
>> is under a memcg other than root.
>>
>> we show /proc/meminfo base on container's memory cgroup.
>> because there are lots of info can't be provide by memcg, and
>> the cmds such as top, free just use some entries of /proc/meminfo,
>> we replace those entries by memory cgroup.
>>
>> if container has no memcg, we will show host's /proc/meminfo
>> as before.
>>
>> there is no idea how to deal with Buffers,I just set it zero,
>> It's strange if Buffers bigger than MemTotal.
>>
>> Signed-off-by: Gao feng<gaofeng@cn.fujitsu.com>
>
> Nack, this type of thing was initially tried with cpusets when a thread
> was bound to a subset of nodes, i.e. only show the total amount of memory
> spanned by those nodes.
>

Hmm. How about having memory.meminfo under memory cgroup directory and
use it with bind mount ? (container tools will be able to help it.)
Then, container applications(top,free,etc..) can read the values they wants.
If admins don't want it, they'll not use bind mount.

Thanks,
-Kame





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
