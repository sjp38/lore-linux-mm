Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 0AE288D0047
	for <linux-mm@kvack.org>; Fri, 11 May 2012 15:20:40 -0400 (EDT)
Date: Fri, 11 May 2012 14:20:36 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v2 04/29] slub: always get the cache from its page in
 kfree
In-Reply-To: <4FAD6449.2060201@parallels.com>
Message-ID: <alpine.DEB.2.00.1205111418350.386@router.home>
References: <1336758272-24284-1-git-send-email-glommer@parallels.com> <1336758272-24284-5-git-send-email-glommer@parallels.com> <alpine.DEB.2.00.1205111251420.31049@router.home> <4FAD531D.6030007@parallels.com> <alpine.DEB.2.00.1205111305570.386@router.home>
 <4FAD566C.3000804@parallels.com> <alpine.DEB.2.00.1205111316540.386@router.home> <4FAD585A.4070007@parallels.com> <alpine.DEB.2.00.1205111331010.386@router.home> <4FAD5DA2.70803@parallels.com> <alpine.DEB.2.00.1205111354540.386@router.home>
 <4FAD6169.8090409@parallels.com> <alpine.DEB.2.00.1205111407280.386@router.home> <4FAD6449.2060201@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Greg Thelen <gthelen@google.com>, Suleiman Souhlal <suleiman@google.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, devel@openvz.org, Pekka Enberg <penberg@cs.helsinki.fi>

On Fri, 11 May 2012, Glauber Costa wrote:

> > I see that. But there are other subsystems from slab allocators that do
> > the same. There are also objects that may be used by multiple processes.
>
> This is also true for normal user pages. And then, we do what memcg does:
> first one to touch, gets accounted. I don't think deviating from the memcg
> behavior for user pages makes much sense here.
>
> A cache won't go away while it still have objects, even after the memcg is
> removed (it is marked as dead)

Ok so we will have some dead pages around that are then repatriated to
the / set?

> > Hmmm.. Would be better to have a hierachy there. /proc/slabinfo is more
> > legacy.
>
> I can take a look at that then. Assuming you agree with all the rest, is
> looking into that a pre-requisite for merging, or is something that can be
> deferred for a phase2 ? (We still don't do shrinkers, for instance, so this is
> sure to have a phase2)

Not a prerequisite for merging but note that I intend to rework the
allocators to extract common code so that they have the same sysfs
interface, error reporting and failure scenarios. We can at that time
also add support for /sys/kernel/slab to memcg. (/sys/memcg/<name>/slab/* ?)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
