Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 89E116B0071
	for <linux-mm@kvack.org>; Wed,  4 Jul 2012 05:42:57 -0400 (EDT)
Message-ID: <4FF40F79.60901@parallels.com>
Date: Wed, 4 Jul 2012 13:40:09 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 1/2] memcg: add res_counter_usage_safe()
References: <4FF3B0DC.5090508@jp.fujitsu.com> <20120704091428.GB7881@cmpxchg.org> <4FF40D33.4030704@jp.fujitsu.com>
In-Reply-To: <4FF40D33.4030704@jp.fujitsu.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, linux-mm <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Tejun Heo <tj@kernel.org>

On 07/04/2012 01:30 PM, Kamezawa Hiroyuki wrote:
>>
> 
> I think asking applications to handle usage > limit case will cause
> trouble and we can keep simple interface by lying here. And,
> applications doesn't need to handle this case.
> 
> From the viewpoint of our enterprise service, it's better to keep
> usage <= limit for avoiding unnecessary, unimportant, troubles.
> 
> Thanks,
> -Kame

One thing to keep in mind, is that usage is already a lie. Mostly
because of batching.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
