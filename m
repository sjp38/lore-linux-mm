Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 6425E6B0044
	for <linux-mm@kvack.org>; Wed, 14 Mar 2012 20:50:19 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 6C0313EE0C0
	for <linux-mm@kvack.org>; Thu, 15 Mar 2012 09:50:17 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4D88745DE5C
	for <linux-mm@kvack.org>; Thu, 15 Mar 2012 09:50:17 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 347F045DE5A
	for <linux-mm@kvack.org>; Thu, 15 Mar 2012 09:50:17 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 239C01DB8054
	for <linux-mm@kvack.org>; Thu, 15 Mar 2012 09:50:17 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id CF8ED1DB804E
	for <linux-mm@kvack.org>; Thu, 15 Mar 2012 09:50:16 +0900 (JST)
Message-ID: <4F613C5B.8030304@jp.fujitsu.com>
Date: Thu, 15 Mar 2012 09:48:27 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 02/13] memcg: Kernel memory accounting infrastructure.
References: <1331325556-16447-1-git-send-email-ssouhlal@FreeBSD.org> <1331325556-16447-3-git-send-email-ssouhlal@FreeBSD.org> <4F5C5E54.2020408@parallels.com> <20120313152446.28b0d696.kamezawa.hiroyu@jp.fujitsu.com> <4F5F236A.1070609@parallels.com> <20120314091526.3c079693.kamezawa.hiroyu@jp.fujitsu.com> <4F608F25.3010700@parallels.com>
In-Reply-To: <4F608F25.3010700@parallels.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Suleiman Souhlal <ssouhlal@FreeBSD.org>, cgroups@vger.kernel.org, suleiman@google.com, penberg@kernel.org, cl@linux.com, yinghan@google.com, hughd@google.com, gthelen@google.com, peterz@infradead.org, dan.magenheimer@oracle.com, hannes@cmpxchg.org, mgorman@suse.de, James.Bottomley@HansenPartnership.com, linux-mm@kvack.org, devel@openvz.org, linux-kernel@vger.kernel.org

(2012/03/14 21:29), Glauber Costa wrote:


>>   - What happens when a new cgroup created ?
> 
> mem_cgroup_create() is called =)
> Heh, jokes apart, I don't really follow here. What exactly do you mean? 
> There shouldn't be anything extremely out of the ordinary.
> 


Sorry, too short words.

Assume a cgroup with
	cgroup.memory.limit_in_bytes=1G
	cgroup.memory.kmem.limit_in_bytes=400M

When a child cgroup is created, what should be the default values.
'unlimited' as current implementation ?
Hmm..maybe yes.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
