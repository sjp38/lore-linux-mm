Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 255106B0004
	for <linux-mm@kvack.org>; Mon, 21 Jan 2013 11:12:08 -0500 (EST)
Message-ID: <50FD68E1.2070303@parallels.com>
Date: Mon, 21 Jan 2013 20:12:17 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 4/6] memcg: replace cgroup_lock with memcg specific
 memcg_lock
References: <1358766813-15095-1-git-send-email-glommer@parallels.com> <1358766813-15095-5-git-send-email-glommer@parallels.com> <20130121144919.GO7798@dhcp22.suse.cz> <50FD5AC0.9020406@parallels.com> <20130121152032.GP7798@dhcp22.suse.cz> <50FD6003.8060703@parallels.com> <20130121160731.GQ7798@dhcp22.suse.cz>
In-Reply-To: <20130121160731.GQ7798@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, kamezawa.hiroyu@jp.fujitsu.com

On 01/21/2013 08:07 PM, Michal Hocko wrote:
>> > And the reason why kmemcg holds the set_limit mutex
>> > is just to protect from itself, then there is no *need* to hold any
>> > extra lock (and we'll never be able to stop holding the creation lock,
>> > whatever it is). So my main point here is not memcg_mutex vs
>> > set_limit_mutex, but rather, memcg_mutex is needed anyway, and once it
>> > is taken, the set_limit_mutex *can* be held, but doesn't need to.
> So you can update kmem specific usage of set_limit_mutex.
Meaning ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
