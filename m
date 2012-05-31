Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 21F616B005C
	for <linux-mm@kvack.org>; Wed, 30 May 2012 20:55:56 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id B38BE3EE0AE
	for <linux-mm@kvack.org>; Thu, 31 May 2012 09:55:54 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9A7DB45DE4E
	for <linux-mm@kvack.org>; Thu, 31 May 2012 09:55:54 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 85EB945DE4F
	for <linux-mm@kvack.org>; Thu, 31 May 2012 09:55:54 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 76291E08004
	for <linux-mm@kvack.org>; Thu, 31 May 2012 09:55:54 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2E026E08002
	for <linux-mm@kvack.org>; Thu, 31 May 2012 09:55:54 +0900 (JST)
Message-ID: <4FC6C111.2060108@jp.fujitsu.com>
Date: Thu, 31 May 2012 09:53:37 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] meminfo: show /proc/meminfo base on container's memcg
References: <1338260214-21919-1-git-send-email-gaofeng@cn.fujitsu.com> <alpine.DEB.2.00.1205301433490.9716@chino.kir.corp.google.com> <4FC6B68C.2070703@jp.fujitsu.com> <CAHGf_=pFbsy4FO_UNu6O1-KyTd6O=pkmR8=3EGuZB5Reu3Vb9w@mail.gmail.com> <4FC6BC3E.5010807@jp.fujitsu.com> <alpine.DEB.2.00.1205301737530.25774@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1205301737530.25774@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Gao feng <gaofeng@cn.fujitsu.com>, hannes@cmpxchg.org, mhocko@suse.cz, bsingharora@gmail.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, containers@lists.linux-foundation.org

(2012/05/31 9:44), David Rientjes wrote:
> On Thu, 31 May 2012, Kamezawa Hiroyuki wrote:
>
>> My test with sysfs node's meminfo seems to work...
>>
>> [root@rx100-1 qqm]# mount --bind /sys/devices/system/node/node0/meminfo
>> /proc/meminfo
>> [root@rx100-1 qqm]# cat /proc/meminfo
>>
>> Node 0 MemTotal:        8379636 kB
>
> This doesn't seem like a good idea unless the application supports the
> "Node 0" prefix in /proc/meminfo.
>
Of course, /cgroup/memory/..../memory.meminfo , a new file, will use the same
format of /proc/meminfo. Above is just an example of bind-mount.

> If any application really cares about the amount of memory available to
> it, it should be taught to be memcg aware.  Then do something like
>

Considering the container as a kind of virtualization, Some kind of
transparent way is required.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
