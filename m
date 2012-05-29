Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id 021CC6B006C
	for <linux-mm@kvack.org>; Tue, 29 May 2012 12:49:45 -0400 (EDT)
Date: Tue, 29 May 2012 11:05:16 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH v3 13/28] slub: create duplicate cache
In-Reply-To: <4FC4F1A7.2010206@parallels.com>
Message-ID: <alpine.DEB.2.00.1205291101580.6723@router.home>
References: <1337951028-3427-1-git-send-email-glommer@parallels.com> <1337951028-3427-14-git-send-email-glommer@parallels.com> <alpine.DEB.2.00.1205290932530.4666@router.home> <4FC4F1A7.2010206@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>, Greg Thelen <gthelen@google.com>, Suleiman Souhlal <suleiman@google.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, devel@openvz.org, David Rientjes <rientjes@google.com>, Pekka Enberg <penberg@cs.helsinki.fi>

On Tue, 29 May 2012, Glauber Costa wrote:

> Accounting pages seems just crazy to me. If new allocators come in the future,
> organizing the pages in a different way, instead of patching it here and
> there, we need to totally rewrite this.

Quite to the contrary. We could either pass a THIS_IS_A_SLAB page flag to
the page allocator call or have a special call that does the accounting
and then calls the page allocator. The code could be completely in
cgroups. There would be no changes to the allocators aside from setting
the flag or calling the alternate page allocator functions.

> > Why do you need to increase the refcount? You made a full copy right?
>
> Yes, but I don't want this copy to go away while we have other caches around.

You copied all metadata so what is there that you would still need should
the other copy go away?

> So, in the memcg internals, I used a different reference counter, to avoid
> messing with this one. I could use that, and leave the original refcnt alone.
> Would you prefer this?

The refcounter is really not the issue.

I am a bit worried about the various duplicate features here and there.
The approach is not tightened down yet.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
