Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id C58876B0005
	for <linux-mm@kvack.org>; Mon, 21 Jan 2013 02:33:12 -0500 (EST)
Message-ID: <50FCEF40.8040709@parallels.com>
Date: Mon, 21 Jan 2013 11:33:20 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 2/7] memcg: split part of memcg creation to css_online
References: <1357897527-15479-1-git-send-email-glommer@parallels.com> <1357897527-15479-3-git-send-email-glommer@parallels.com> <20130118152526.GF10701@dhcp22.suse.cz>
In-Reply-To: <20130118152526.GF10701@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>

On 01/18/2013 07:25 PM, Michal Hocko wrote:
>> -	spin_lock_init(&memcg->move_lock);
>> > +	memcg->swappiness = mem_cgroup_swappiness(parent);
> Please move this up to oom_kill_disable and use_hierarchy
> initialization.

One thing: wouldn't moving it to inside use_hierarchy be a change of
behavior here?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
