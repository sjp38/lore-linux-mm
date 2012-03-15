Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id 95FB96B0044
	for <linux-mm@kvack.org>; Thu, 15 Mar 2012 07:08:53 -0400 (EDT)
Message-ID: <4F61CD63.4090007@parallels.com>
Date: Thu, 15 Mar 2012 15:07:15 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 02/13] memcg: Kernel memory accounting infrastructure.
References: <1331325556-16447-1-git-send-email-ssouhlal@FreeBSD.org> <1331325556-16447-3-git-send-email-ssouhlal@FreeBSD.org> <4F5C5E54.2020408@parallels.com> <20120313152446.28b0d696.kamezawa.hiroyu@jp.fujitsu.com> <4F5F236A.1070609@parallels.com> <20120314091526.3c079693.kamezawa.hiroyu@jp.fujitsu.com> <4F608F25.3010700@parallels.com> <4F613C5B.8030304@jp.fujitsu.com>
In-Reply-To: <4F613C5B.8030304@jp.fujitsu.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Suleiman Souhlal <ssouhlal@FreeBSD.org>, cgroups@vger.kernel.org, suleiman@google.com, penberg@kernel.org, cl@linux.com, yinghan@google.com, hughd@google.com, gthelen@google.com, peterz@infradead.org, dan.magenheimer@oracle.com, hannes@cmpxchg.org, mgorman@suse.de, James.Bottomley@HansenPartnership.com, linux-mm@kvack.org, devel@openvz.org, linux-kernel@vger.kernel.org

On 03/15/2012 04:48 AM, KAMEZAWA Hiroyuki wrote:
>>>    - What happens when a new cgroup created ?
>> >
>> >  mem_cgroup_create() is called =)
>> >  Heh, jokes apart, I don't really follow here. What exactly do you mean?
>> >  There shouldn't be anything extremely out of the ordinary.
>> >
>
> Sorry, too short words.
>
> Assume a cgroup with
> 	cgroup.memory.limit_in_bytes=1G
> 	cgroup.memory.kmem.limit_in_bytes=400M
>
> When a child cgroup is created, what should be the default values.
> 'unlimited' as current implementation ?
> Hmm..maybe yes.

I think so, yes. I see no reason to come up with any default values
in memcg. Yes, your allocations can fail due to your parent limits.
But since I never heard of any machine with
9223372036854775807 bytes of memory, that is true even for the root memcg =)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
