Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id CE5D86B004D
	for <linux-mm@kvack.org>; Thu, 22 Nov 2012 09:02:37 -0500 (EST)
Message-ID: <1353592956.10902.5.camel@joe-AO722>
Subject: Re: [PATCH 2/2] memcg: debugging facility to access dangling memcgs.
From: Joe Perches <joe@perches.com>
Date: Thu, 22 Nov 2012 06:02:36 -0800
In-Reply-To: <50AE2E5E.7010006@parallels.com>
References: <1353580190-14721-1-git-send-email-glommer@parallels.com>
	 <1353580190-14721-3-git-send-email-glommer@parallels.com>
	 <50AE0031.1020404@parallels.com> <50AE2E5E.7010006@parallels.com>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, kamezawa.hiroyu@jp.fujitsu.com, Tejun Heo <tj@kernel.org>, apw@canonical.com

On Thu, 2012-11-22 at 17:53 +0400, Glauber Costa wrote:
> On 11/22/2012 02:36 PM, Glauber Costa wrote:
> >> @@ -5933,6 +6071,7 @@ static void __mem_cgroup_free(struct mem_cgroup *memcg)
> >> >  	 * the cgroup_lock.
> >> >  	 */
> >> >  	disarm_static_keys(memcg);
> >> > +
> >> >  	if (size < PAGE_SIZE)
> >> >  		kfree(memcg);
> >> >  	else
> 
> Joe,
> 
> since you removed the code from my former e-mail:

Because you quoted a whole bunch of lines that
included newlines 

> That one after "disarm_static_keys".

Vertical spacing has many uses within a functional
block.  I don't see anything wrong with that one.

The one I suspected you meant was:

> +static inline void memcg_dangling_add(struct mem_cgroup *memcg)
> +{
> +
> +     memcg->memcg_name = kstrdup(cgroup_name(memcg->css.cgroup), GFP_KERNEL);

I think a blank line after an initial { is suspect.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
