Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 5B3816B0072
	for <linux-mm@kvack.org>; Thu, 22 Nov 2012 08:53:53 -0500 (EST)
Message-ID: <50AE2E5E.7010006@parallels.com>
Date: Thu, 22 Nov 2012 17:53:34 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] memcg: debugging facility to access dangling memcgs.
References: <1353580190-14721-1-git-send-email-glommer@parallels.com> <1353580190-14721-3-git-send-email-glommer@parallels.com> <50AE0031.1020404@parallels.com>
In-Reply-To: <50AE0031.1020404@parallels.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, kamezawa.hiroyu@jp.fujitsu.com, Tejun Heo <tj@kernel.org>, apw@canonical.com, Joe Perches <joe@perches.com>

On 11/22/2012 02:36 PM, Glauber Costa wrote:
>> @@ -5933,6 +6071,7 @@ static void __mem_cgroup_free(struct mem_cgroup *memcg)
>> >  	 * the cgroup_lock.
>> >  	 */
>> >  	disarm_static_keys(memcg);
>> > +
>> >  	if (size < PAGE_SIZE)
>> >  		kfree(memcg);
>> >  	else

Joe,

since you removed the code from my former e-mail:

That one after "disarm_static_keys".

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
