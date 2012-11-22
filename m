Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id AF4166B0074
	for <linux-mm@kvack.org>; Thu, 22 Nov 2012 10:02:11 -0500 (EST)
Date: Thu, 22 Nov 2012 15:02:04 +0000
From: Andy Whitcroft <apw@canonical.com>
Subject: Re: [PATCH 2/2] memcg: debugging facility to access dangling memcgs.
Message-ID: <20121122150204.GB30773@dm>
References: <1353580190-14721-1-git-send-email-glommer@parallels.com>
 <1353580190-14721-3-git-send-email-glommer@parallels.com>
 <50AE0031.1020404@parallels.com>
 <50AE2E5E.7010006@parallels.com>
 <1353592956.10902.5.camel@joe-AO722>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1353592956.10902.5.camel@joe-AO722>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, kamezawa.hiroyu@jp.fujitsu.com, Tejun Heo <tj@kernel.org>

On Thu, Nov 22, 2012 at 06:02:36AM -0800, Joe Perches wrote:
> On Thu, 2012-11-22 at 17:53 +0400, Glauber Costa wrote:
> > On 11/22/2012 02:36 PM, Glauber Costa wrote:
> > >> @@ -5933,6 +6071,7 @@ static void __mem_cgroup_free(struct mem_cgroup *memcg)
> > >> >  	 * the cgroup_lock.
> > >> >  	 */
> > >> >  	disarm_static_keys(memcg);
> > >> > +
> > >> >  	if (size < PAGE_SIZE)
> > >> >  		kfree(memcg);
> > >> >  	else
> > 
> > Joe,
> > 
> > since you removed the code from my former e-mail:
> 
> Because you quoted a whole bunch of lines that
> included newlines 
> 
> > That one after "disarm_static_keys".
> 
> Vertical spacing has many uses within a functional
> block.  I don't see anything wrong with that one.
> 
> The one I suspected you meant was:
> 
> > +static inline void memcg_dangling_add(struct mem_cgroup *memcg)
> > +{
> > +
> > +     memcg->memcg_name = kstrdup(cgroup_name(memcg->css.cgroup), GFP_KERNEL);
> 
> I think a blank line after an initial { is suspect.


Yeah it is a bit odd to go changing the spacing in a function when you
arn't making any other change, but if the code is clearer with it so be
it.  The blank line at the start of a block is a little less obviously
ever useful.

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
