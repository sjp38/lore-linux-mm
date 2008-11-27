Date: Thu, 27 Nov 2008 04:59:13 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] memcg reclaim shouldn't change zone->recent_rotated statics.
Message-ID: <20081127035913.GA4168@cmpxchg.org>
References: <20081125121842.26C5.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20081125155422.6ab07caf.akpm@linux-foundation.org> <20081127124946.912541e2.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20081127124946.912541e2.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, riel@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Nov 27, 2008 at 12:49:46PM +0900, KAMEZAWA Hiroyuki wrote:
> On Tue, 25 Nov 2008 15:54:22 -0800
> Andrew Morton <akpm@linux-foundation.org> wrote:
> 
> > On Tue, 25 Nov 2008 12:22:53 +0900 (JST)
> > KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> > 
> > > +	if (scan_global_lru(sc))
> > 
> > mutter.  scan_global_lru() is a terrible function name.  Anyone reading
> > that code would expect that this function, umm, scans the global LRU.
> > 
> > gcc has a nice convention wherein such functions have a name ending in
> > "_p" (for "predicate").  Don't do this :)
> > 
> 
> Hmm, I'll prepare renaming patch.
> 
> scan_global_lru_p() ?

That only works well when you don't have to use underscores, "listp"
or in Lisps where words can be hyphenated "loaded-module-p". 

But scan_global_lru_p() looks terrible.

> or under_scanning_global_lru() ?

How about just scanning_global_lru()?

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
