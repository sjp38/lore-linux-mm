Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id E46026B0205
	for <linux-mm@kvack.org>; Fri, 14 Sep 2012 07:34:02 -0400 (EDT)
Date: Fri, 14 Sep 2012 13:34:00 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v2] memcg: clean up networking headers file inclusion
Message-ID: <20120914113400.GI28039@dhcp22.suse.cz>
References: <20120914112118.GG28039@dhcp22.suse.cz>
 <50531339.1000805@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <50531339.1000805@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Sachin Kamat <sachin.kamat@linaro.org>

On Fri 14-09-12 15:21:29, Glauber Costa wrote:
> On 09/14/2012 03:21 PM, Michal Hocko wrote:
> > Hi,
> > so I did some more changes to ifdefery of sock kmem part. The patch is
> > below. 
> > Glauber please have a look at it. I do not think any of the
> > functionality wrapped inside CONFIG_MEMCG_KMEM without CONFIG_INET is
> > reusable for generic CONFIG_MEMCG_KMEM, right?
> Almost right.
> 
> 
> 
> >  }
> >  
> >  /* Writing them here to avoid exposing memcg's inner layout */
> > -#ifdef CONFIG_MEMCG_KMEM
> > -#include <net/sock.h>
> > -#include <net/ip.h>
> > +#if defined(CONFIG_INET) && defined(CONFIG_MEMCG_KMEM)
> >  
> >  static bool mem_cgroup_is_root(struct mem_cgroup *memcg);
> 
> This one is. ^^^^

But this is just a forward declaration. And btw. it makes my compiler
complain about:
mm/memcontrol.c:421: warning: a??mem_cgroup_is_roota?? declared inline after being called
mm/memcontrol.c:421: warning: previous declaration of a??mem_cgroup_is_roota?? was here

But I didn't care much yet. It is probaly that my compiler is too old to
be clever about this.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
