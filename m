Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 2831D6B004D
	for <linux-mm@kvack.org>; Fri, 20 Mar 2009 14:27:21 -0400 (EDT)
Subject: Re: [PATCH 0/2] Make the Unevictable LRU available on NOMMU
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <12759.1237566272@redhat.com>
References: <1237565305.27431.48.camel@lts-notebook>
	 <20090312100049.43A3.A69D9226@jp.fujitsu.com>
	 <20090313173343.10169.58053.stgit@warthog.procyon.org.uk>
	 <28c262360903131727l4ef41db5xf917c7c5eb4825a8@mail.gmail.com>
	 <12759.1237566272@redhat.com>
Content-Type: text/plain
Date: Fri, 20 Mar 2009 14:30:15 -0400
Message-Id: <1237573815.27431.122.camel@lts-notebook>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Howells <dhowells@redhat.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, kosaki.motohiro@jp.fujitsu.com, torvalds@linux-foundation.org, peterz@infradead.org, nrik.Berkhan@ge.com, uclinux-dev@uclinux.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hannes@cmpxchg.org, riel@surriel.com
List-ID: <linux-mm.kvack.org>

On Fri, 2009-03-20 at 16:24 +0000, David Howells wrote:
> Lee Schermerhorn <Lee.Schermerhorn@hp.com> wrote:
> 
> > I just want to point out [again :)] that removing the ramfs pages from
> > the lru will prevent them from being migrated
> 
> This is less of an issue for NOMMU kernels, since you can't migrate pages that
> are mapped.


Agreed.  So, you could eliminate them [ramfs pages] from the lru for
just the nommu kernels, if you wanted to go that route.

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
