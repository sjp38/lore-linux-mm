Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id D66B46B004D
	for <linux-mm@kvack.org>; Wed, 16 May 2012 04:32:36 -0400 (EDT)
Message-ID: <4FB365A1.6040101@parallels.com>
Date: Wed, 16 May 2012 12:30:25 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5 2/2] decrement static keys on real destroy time
References: <1336767077-25351-1-git-send-email-glommer@parallels.com> <1336767077-25351-3-git-send-email-glommer@parallels.com> <4FB058D8.6060707@jp.fujitsu.com> <4FB3431C.3050402@parallels.com> <4FB3518B.3090205@parallels.com> <4FB3652D.2040909@jp.fujitsu.com>
In-Reply-To: <4FB3652D.2040909@jp.fujitsu.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, devel@openvz.org, netdev@vger.kernel.org, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>

On 05/16/2012 12:28 PM, KAMEZAWA Hiroyuki wrote:
>> For the record, I compiled test it many times, and the problem that Li
>> >  wondered about seems not to exist.
>> >  
> Ah...Hmm.....I guess dependency problem will be found in -mm if any rather than
> netdev...

Yes. As I said, this only touches stuff in core memcg and the memcg
specific file. Any conflicts should come from other memcg fixes that may
have got into the tree...
> David, can this bug-fix patch goes via -mm tree ? Or will you pick up ?
> 
> CC'ed David Miller and Andrew Morton.
> 
> Thanks,
> -Kame
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
