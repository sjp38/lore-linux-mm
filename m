Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 098C66B005C
	for <linux-mm@kvack.org>; Fri, 20 Jan 2012 22:45:37 -0500 (EST)
Received: by iadj38 with SMTP id j38so2346919iad.14
        for <linux-mm@kvack.org>; Fri, 20 Jan 2012 19:45:37 -0800 (PST)
Date: Fri, 20 Jan 2012 19:45:23 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 1/3] idr: make idr_get_next() good for rcu_read_lock()
In-Reply-To: <20120120154807.c55c9ac7.akpm@linux-foundation.org>
Message-ID: <alpine.LSU.2.00.1201201922110.1396@eggly.anvils>
References: <alpine.LSU.2.00.1201182155480.7862@eggly.anvils> <1326958401.1113.22.camel@edumazet-laptop> <CAOS58YO585NYMLtmJv3f9vVdadFqoWF+Y5vZ6Va=2qHELuePJA@mail.gmail.com> <1326979818.2249.12.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <alpine.LSU.2.00.1201191235330.29542@eggly.anvils> <alpine.LSU.2.00.1201191247210.29542@eggly.anvils> <20120120154807.c55c9ac7.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>, Eric Dumazet <eric.dumazet@gmail.com>, Li Zefan <lizf@cn.fujitsu.com>, Manfred Spraul <manfred@colorfullife.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Ying Han <yinghan@google.com>, Greg Thelen <gthelen@google.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 20 Jan 2012, Andrew Morton wrote:
> On Thu, 19 Jan 2012 12:48:48 -0800 (PST)
> Hugh Dickins <hughd@google.com> wrote:
> > Copied comment on RCU locking from idr_find().
> > 
> > + *
> > + * This function can be called under rcu_read_lock(), given that the leaf
> > + * pointers lifetimes are correctly managed.
> 
> Awkward comment.  It translates to "..., because the leaf pointers
> lifetimes are correctly managed".
> 
> Is that what we really meant?  Or did we mean "..., provided the leaf
> pointers lifetimes are correctly managed"?

You are right, and part of me realized that even as I copied in the
comment.  I wanted to express the same optimism for idr_get_next() 
as was already expressed for idr_find() - whatever it meant ;)

I thought it was meaning a bit of both: idr.c is managing its end well
enough that rcu_read_lock() can now be used, but the caller has to
manage their locking and lifetimes appropriately too.

> 
> Also, "pointers" should have been "pointer" or "pointer's"!

You're afraid of Linus turning his "its/it's" wrath from Al to yourself.

Since "lifetimes" is in the plural, I think it would have to be
"pointers'" - I _think_ that's correct, rather than "pointers's".

But then, it's not the lifetimes of the pointers, but the lifetimes
of the objects that they point to, that's in question.  So what it
ought to say is...

... falls asleep.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
