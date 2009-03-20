Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 415916B0055
	for <linux-mm@kvack.org>; Fri, 20 Mar 2009 12:23:55 -0400 (EDT)
From: David Howells <dhowells@redhat.com>
In-Reply-To: <1237565305.27431.48.camel@lts-notebook>
References: <1237565305.27431.48.camel@lts-notebook> <20090312100049.43A3.A69D9226@jp.fujitsu.com> <20090313173343.10169.58053.stgit@warthog.procyon.org.uk> <28c262360903131727l4ef41db5xf917c7c5eb4825a8@mail.gmail.com>
Subject: Re: [PATCH 0/2] Make the Unevictable LRU available on NOMMU
Date: Fri, 20 Mar 2009 16:24:32 +0000
Message-ID: <12759.1237566272@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: dhowells@redhat.com, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, kosaki.motohiro@jp.fujitsu.com, torvalds@linux-foundation.org, peterz@infradead.org, nrik.Berkhan@ge.com, uclinux-dev@uclinux.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hannes@cmpxchg.org, riel@surriel.com
List-ID: <linux-mm.kvack.org>

Lee Schermerhorn <Lee.Schermerhorn@hp.com> wrote:

> I just want to point out [again :)] that removing the ramfs pages from
> the lru will prevent them from being migrated

This is less of an issue for NOMMU kernels, since you can't migrate pages that
are mapped.

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
