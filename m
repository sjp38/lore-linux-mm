Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx101.postini.com [74.125.245.101])
	by kanga.kvack.org (Postfix) with SMTP id ADBC56B004A
	for <linux-mm@kvack.org>; Thu, 16 Feb 2012 02:02:49 -0500 (EST)
Received: by bkty12 with SMTP id y12so2163620bkt.14
        for <linux-mm@kvack.org>; Wed, 15 Feb 2012 23:02:47 -0800 (PST)
Message-ID: <4F3CAA13.1090906@openvz.org>
Date: Thu, 16 Feb 2012 11:02:43 +0400
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] memcg: use vm_swappiness from current memcg
References: <20120215162830.13902.60256.stgit@zurg>	<20120215162834.13902.37262.stgit@zurg> <20120216091511.350882a7.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20120216091511.350882a7.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

KAMEZAWA Hiroyuki wrote:
> On Wed, 15 Feb 2012 20:28:34 +0400
> Konstantin Khlebnikov<khlebnikov@openvz.org>  wrote:
>
>> At this point this is always the same cgroup, but it allows to drop one argument.
>>
>> Signed-off-by: Konstantin Khlebnikov<khlebnikov@openvz.org>
>
> Do you mean "no logic change but clean up, dropping an argument" ?
>
> I'm not sure using complicated sc->  is easier than passing an argument..

It also was cleanup-preparation for "memory book keeping",
there I replace struct mem_cgroup_zone *mz with struct book *book,
struct book doesn't know anything about memory-cgroups.

>
> Acked-by: KAMEZAWA Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com>
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email:<a href=mailto:"dont@kvack.org">  email@kvack.org</a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
