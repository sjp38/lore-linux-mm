Date: Thu, 28 Feb 2008 08:08:17 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [PATCH 01/15] memcg: mm_match_cgroup not vm_match_cgroup
In-Reply-To: <20080227232625.26f736f8.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0802280801290.27005@blonde.site>
References: <Pine.LNX.4.64.0802252327490.27067@blonde.site>
 <Pine.LNX.4.64.0802252334190.27067@blonde.site> <20080227194744.4de606e3.akpm@linux-foundation.org>
 <alpine.DEB.1.00.0802272317380.24391@chino.kir.corp.google.com>
 <20080227232625.26f736f8.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hirokazu Takahashi <taka@valinux.co.jp>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 27 Feb 2008, Andrew Morton wrote:
> On Wed, 27 Feb 2008 23:19:08 -0800 (PST) David Rientjes <rientjes@google.com> wrote:
> > 
> > Writing vm_match_cgroup() as a static inline function in 
> > include/linux/memcontrol.h created all the sparc build errors about two 
> > weeks ago because of the dependency on linux/mm.h and linux/rcupdate.h.
> 
> It's become an faq already?  Should have put a comment in there..
> 
> That's the second ugly hack in that file because of missing includes.  It's
> preferable to add the needed includes, or just temper our little
> inline-everything fetish.  
> 
> Oh well.

Temper our inline-everything fetish and say "Oh well".  We prefer
inline functions to macros, we prefer to avoid include hell, macros
are the key to avoiding include hell.

Oh well: it really doesn't matter much, both David and I left our
!CONFIG_CGROUP_MEM_CONT versions as static inlines, so those without
MEM_CONT will be doing that part of build testing for those with it.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
