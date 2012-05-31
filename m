Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 19F4F6B0062
	for <linux-mm@kvack.org>; Wed, 30 May 2012 20:22:39 -0400 (EDT)
Received: by ggm4 with SMTP id 4so497650ggm.14
        for <linux-mm@kvack.org>; Wed, 30 May 2012 17:22:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4FC6B68C.2070703@jp.fujitsu.com>
References: <1338260214-21919-1-git-send-email-gaofeng@cn.fujitsu.com>
 <alpine.DEB.2.00.1205301433490.9716@chino.kir.corp.google.com> <4FC6B68C.2070703@jp.fujitsu.com>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Wed, 30 May 2012 20:22:16 -0400
Message-ID: <CAHGf_=pFbsy4FO_UNu6O1-KyTd6O=pkmR8=3EGuZB5Reu3Vb9w@mail.gmail.com>
Subject: Re: [PATCH] meminfo: show /proc/meminfo base on container's memcg
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: David Rientjes <rientjes@google.com>, Gao feng <gaofeng@cn.fujitsu.com>, hannes@cmpxchg.org, mhocko@suse.cz, bsingharora@gmail.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, containers@lists.linux-foundation.org

On Wed, May 30, 2012 at 8:08 PM, Kamezawa Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> (2012/05/31 6:38), David Rientjes wrote:
>>
>> On Tue, 29 May 2012, Gao feng wrote:
>>
>>> cgroup and namespaces are used for creating containers but some of
>>> information is not isolated/virtualized. This patch is for isolating
>>> /proc/meminfo
>>> information per container, which uses memory cgroup. By this, top,free
>>> and other tools under container can work as expected(show container's
>>> usage) without changes.
>>>
>>> This patch is a trial to show memcg's info in /proc/meminfo if 'current'
>>> is under a memcg other than root.
>>>
>>> we show /proc/meminfo base on container's memory cgroup.
>>> because there are lots of info can't be provide by memcg, and
>>> the cmds such as top, free just use some entries of /proc/meminfo,
>>> we replace those entries by memory cgroup.
>>>
>>> if container has no memcg, we will show host's /proc/meminfo
>>> as before.
>>>
>>> there is no idea how to deal with Buffers,I just set it zero,
>>> It's strange if Buffers bigger than MemTotal.
>>>
>>> Signed-off-by: Gao feng<gaofeng@cn.fujitsu.com>
>>
>>
>> Nack, this type of thing was initially tried with cpusets when a thread
>> was bound to a subset of nodes, i.e. only show the total amount of memory
>> spanned by those nodes.
>>
>
> Hmm. How about having memory.meminfo under memory cgroup directory and
> use it with bind mount ? (container tools will be able to help it.)
> Then, container applications(top,free,etc..) can read the values they wants.
> If admins don't want it, they'll not use bind mount.

+1. 50% users need namespace separation and others don't. We need a
selectability.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
