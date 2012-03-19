Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 93B696B004A
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 11:33:41 -0400 (EDT)
Date: Mon, 19 Mar 2012 16:33:35 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC][PATCH 1/3] memcg: add methods to access pc->mem_cgroup
Message-ID: <20120319153334.GC31213@tiehlicka.suse.cz>
References: <4F66E6A5.10804@jp.fujitsu.com>
 <4F66E773.4000807@jp.fujitsu.com>
 <4F671138.3000508@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4F671138.3000508@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Han Ying <yinghan@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, suleiman@google.com, n-horiguchi@ah.jp.nec.com, khlebnikov@openvz.org, Tejun Heo <tj@kernel.org>

On Mon 19-03-12 14:58:00, Glauber Costa wrote:
> On 03/19/2012 11:59 AM, KAMEZAWA Hiroyuki wrote:
> > In order to encode pc->mem_cgroup and pc->flags to be in a word,
> > access function to pc->mem_cgroup is required.
> > 
> > This patch replaces access to pc->mem_cgroup with
> >   pc_to_mem_cgroup(pc)          : pc->mem_cgroup
> >   pc_set_mem_cgroup(pc, memcg)  : pc->mem_cgroup = memcg
> > 
> > Following patch will remove pc->mem_cgroup.
> > 
> > Signed-off-by: KAMEZAWA Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com>
> Kame,
> 
> I can't see a reason not to merge this patch right now, regardless of
> the other ones.
 
I am not so sure about that. The patch doesn't do much on its own and
reference to the "following patch" might be confusing. Does it actually
help to rush it now?
-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
