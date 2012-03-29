Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id CABCC6B0044
	for <linux-mm@kvack.org>; Thu, 29 Mar 2012 07:52:18 -0400 (EDT)
Message-ID: <4F744CD6.2080809@parallels.com>
Date: Thu, 29 Mar 2012 13:51:50 +0200
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [RFC] simple system for enable/disable slabs being tracked by
 memcg.
References: <1332952945-15909-1-git-send-email-glommer@parallels.com> <4F73A6E8.8010402@jp.fujitsu.com>
In-Reply-To: <4F73A6E8.8010402@jp.fujitsu.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, Suleiman Souhlal <suleiman@google.com>, Johannes
 Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>

On 03/29/2012 02:03 AM, KAMEZAWA Hiroyuki wrote:
> Hmm, but having private format of list is good ?
> In another idea, how about having 3 files as device cgroup ?
> 
> 	memory.kmem.slabs.allow   (similar to device.allow)
> 	memory.kmem.slabs.deny    (similar to device.deny)
> 	memory.kmem.slabs.list	    (similar to device.list)
> 
I forgot to comment on this point.

I fear #files explosion, but since one the drawbacks of our beloved cgroups
IMHO is the sheer inconsistency among them (which we're trying to fix), if
there is precedence for that, we can use it. Certainly solves the problem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
