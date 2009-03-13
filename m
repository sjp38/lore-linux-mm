Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 5483D6B003D
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 07:53:28 -0400 (EDT)
From: David Howells <dhowells@redhat.com>
In-Reply-To: <20090312100049.43A3.A69D9226@jp.fujitsu.com>
References: <20090312100049.43A3.A69D9226@jp.fujitsu.com> <20090311170207.1795cad9.akpm@linux-foundation.org> <28c262360903111735s2b0c43a3pd48fcf8d55416ae3@mail.gmail.com>
Subject: Re: [PATCH] NOMMU: Pages allocated to a ramfs inode's pagecache may get wrongly discarded
Date: Fri, 13 Mar 2009 11:53:02 +0000
Message-ID: <27074.1236945182@redhat.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: dhowells@redhat.com, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, torvalds@linux-foundation.org, peterz@infradead.org, Enrik.Berkhan@ge.com, uclinux-dev@uclinux.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@surriel.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> David, Could you please try following patch if you have NOMMU machine?
> it is straightforward porting to nommu.

Is this patch actually sufficient, though?  Surely it requires an alteration
to ramfs to mark the page as being unevictable?

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
