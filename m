Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 235A86B005C
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 05:35:54 -0400 (EDT)
Message-ID: <4FEAD351.2030203@parallels.com>
Date: Wed, 27 Jun 2012 13:33:05 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 06/11] memcg: kmem controller infrastructure
References: <1340633728-12785-1-git-send-email-glommer@parallels.com> <1340633728-12785-7-git-send-email-glommer@parallels.com> <alpine.DEB.2.00.1206260210200.16020@chino.kir.corp.google.com> <4FE97E31.3010201@parallels.com> <alpine.DEB.2.00.1206262100320.24245@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1206262100320.24245@chino.kir.corp.google.com>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Frederic Weisbecker <fweisbec@gmail.com>, Pekka Enberg <penberg@kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, devel@openvz.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, Pekka Enberg <penberg@cs.helsinki.fi>


>>
>> Nothing, but I also don't see how to prevent that.
>
> You can test for current->flags & PF_KTHREAD following the check for
> in_interrupt() and return true, it's what you were trying to do with the
> check for !current->mm.
>

am I right to believe that if not in interrupt context - already ruled 
out - and !(current->flags & PF_KTHREAD), I am guaranteed to have a mm 
context, and thus, don't need to test against it ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
