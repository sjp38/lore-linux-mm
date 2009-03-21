Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id E7D216B003D
	for <linux-mm@kvack.org>; Sat, 21 Mar 2009 06:04:36 -0400 (EDT)
Date: Sat, 21 Mar 2009 11:20:44 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 0/2] Make the Unevictable LRU available on NOMMU
Message-ID: <20090321102044.GA3427@cmpxchg.org>
References: <1237565305.27431.48.camel@lts-notebook> <20090312100049.43A3.A69D9226@jp.fujitsu.com> <20090313173343.10169.58053.stgit@warthog.procyon.org.uk> <28c262360903131727l4ef41db5xf917c7c5eb4825a8@mail.gmail.com> <12759.1237566272@redhat.com> <1237573815.27431.122.camel@lts-notebook>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1237573815.27431.122.camel@lts-notebook>
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: David Howells <dhowells@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, kosaki.motohiro@jp.fujitsu.com, torvalds@linux-foundation.org, peterz@infradead.org, nrik.Berkhan@ge.com, uclinux-dev@uclinux.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, riel@surriel.com
List-ID: <linux-mm.kvack.org>

On Fri, Mar 20, 2009 at 02:30:15PM -0400, Lee Schermerhorn wrote:
> On Fri, 2009-03-20 at 16:24 +0000, David Howells wrote:
> > Lee Schermerhorn <Lee.Schermerhorn@hp.com> wrote:
> > 
> > > I just want to point out [again :)] that removing the ramfs pages from
> > > the lru will prevent them from being migrated
> > 
> > This is less of an issue for NOMMU kernels, since you can't migrate pages that
> > are mapped.
> 
> 
> Agreed.  So, you could eliminate them [ramfs pages] from the lru for
> just the nommu kernels, if you wanted to go that route.

These pages don't come with much overhead anymore when they sit on the
unevictable list, right?  So I don't see much point in special casing
them all over the place.

I have a patchset that decouples the unevictable lru feature from
mlock, enables the latter on nommu and then makes sure ramfs pages go
immediately to the unevictable list so they don't need the scanner to
move them.  This is just wiring up of features we already have.

I will sent this mondayish, need to test it more especially on a NOMMU
setup.

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
