Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id DC2CE6B005A
	for <linux-mm@kvack.org>; Tue, 26 Jun 2012 11:32:26 -0400 (EDT)
Message-ID: <4FE9D568.4050802@parallels.com>
Date: Tue, 26 Jun 2012 19:29:44 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 06/11] memcg: kmem controller infrastructure
References: <1340633728-12785-1-git-send-email-glommer@parallels.com> <1340633728-12785-7-git-send-email-glommer@parallels.com> <20120625161720.ae13ae90.akpm@linux-foundation.org>
In-Reply-To: <20120625161720.ae13ae90.akpm@linux-foundation.org>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Frederic Weisbecker <fweisbec@gmail.com>, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, devel@openvz.org, kamezawa.hiroyu@jp.fujitsu.com, Tejun Heo <tj@kernel.org>, Pekka Enberg <penberg@cs.helsinki.fi>

On 06/26/2012 03:17 AM, Andrew Morton wrote:
>> +	if (ret == -EINTR)  {
>> >+		nofail = true;
>> >+		/*
>> >+		 * __mem_cgroup_try_charge() chose to bypass to root due
>> >+		 * to OOM kill or fatal signal.
> Is "bypass" correct?  Maybe "fall back"?
>

Heh, forgot this one, sorry =(

__mem_cgroup_try_charge does "goto bypass", so I believe the term
"bypass" is better to allow whoever is following this code to follow it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
