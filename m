Date: Wed, 27 Feb 2008 23:26:25 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 01/15] memcg: mm_match_cgroup not vm_match_cgroup
Message-Id: <20080227232625.26f736f8.akpm@linux-foundation.org>
In-Reply-To: <alpine.DEB.1.00.0802272317380.24391@chino.kir.corp.google.com>
References: <Pine.LNX.4.64.0802252327490.27067@blonde.site>
	<Pine.LNX.4.64.0802252334190.27067@blonde.site>
	<20080227194744.4de606e3.akpm@linux-foundation.org>
	<alpine.DEB.1.00.0802272317380.24391@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Hugh Dickins <hugh@veritas.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hirokazu Takahashi <taka@valinux.co.jp>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 27 Feb 2008 23:19:08 -0800 (PST) David Rientjes <rientjes@google.com> wrote:

> On Wed, 27 Feb 2008, Andrew Morton wrote:
> 
> > > -#define vm_match_cgroup(mm, cgroup)	\
> > > +#define mm_match_cgroup(mm, cgroup)	\
> > >  	((cgroup) == rcu_dereference((mm)->mem_cgroup))
> > 
> > Could be written in C, methinks.
> > 
> > Unless we really want to be able to pass a `struct page_cgroup *' in place
> > of arg `mm' here.  If we don't want to be able to do that (prays fervently)
> > then let's sleep happily in the knowledge that the C type system prevents
> > us from doing it accidentally?
> > 
> 
> Writing vm_match_cgroup() as a static inline function in 
> include/linux/memcontrol.h created all the sparc build errors about two 
> weeks ago because of the dependency on linux/mm.h and linux/rcupdate.h.

It's become an faq already?  Should have put a comment in there..

That's the second ugly hack in that file because of missing includes.  It's
preferable to add the needed includes, or just temper our little
inline-everything fetish.  

Oh well.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
