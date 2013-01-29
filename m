Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 72A4A6B009B
	for <linux-mm@kvack.org>; Tue, 29 Jan 2013 11:09:19 -0500 (EST)
Date: Tue, 29 Jan 2013 17:09:12 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v2 5/6] memcg: introduce
 swap_cgroup_init()/swap_cgroup_free()
Message-ID: <20130129160912.GK29574@dhcp22.suse.cz>
References: <510658E3.1020306@oracle.com>
 <510658F7.6050806@oracle.com>
 <20130129145639.GG29574@dhcp22.suse.cz>
 <5107F00E.7070302@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5107F00E.7070302@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jeff Liu <jeff.liu@oracle.com>
Cc: linux-mm@kvack.org, Glauber Costa <glommer@parallels.com>, cgroups@vger.kernel.org

On Tue 29-01-13 23:51:42, Jeff Liu wrote:
> On 01/29/2013 10:56 PM, Michal Hocko wrote:
> > On Mon 28-01-13 18:54:47, Jeff Liu wrote:
> >> Introduce swap_cgroup_init()/swap_cgroup_free() to allocate buffers when creating the first
> >> non-root memcg and deallocate buffers on the last non-root memcg is gone.
> > 
> > I think this deserves more words ;) At least it would be good to
> > describe contexts from which init and free might be called. What are the
> > locking rules.
> > Also swap_cgroup_destroy sounds more in pair with swap_cgroup_init.
> Will improve the comments log as well as fix the naming.  Btw, I named
> it as swap_cgroup_free() because we have mem_cgroup_free() corresponding
> to mem_cgroup_init(). :)

I do see mem_cgroup_alloc and __mem_cgroup_free. Anyway this is not that
important. Consistent naming is not any rule. It is nice to have though.
So take these renaming suggestions as hints rather than you definitely
_have_ to do that.

[...]
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
