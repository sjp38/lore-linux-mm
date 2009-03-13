Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id D1CBD6B003D
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 18:50:17 -0400 (EDT)
Date: Fri, 13 Mar 2009 23:49:08 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] NOMMU: Pages allocated to a ramfs inode's pagecache may get wrongly discarded
Message-ID: <20090313224908.GA2271@cmpxchg.org>
References: <20090312100049.43A3.A69D9226@jp.fujitsu.com> <20090311170207.1795cad9.akpm@linux-foundation.org> <28c262360903111735s2b0c43a3pd48fcf8d55416ae3@mail.gmail.com> <27074.1236945182@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <27074.1236945182@redhat.com>
Sender: owner-linux-mm@kvack.org
To: David Howells <dhowells@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, torvalds@linux-foundation.org, peterz@infradead.org, Enrik.Berkhan@ge.com, uclinux-dev@uclinux.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@surriel.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On Fri, Mar 13, 2009 at 11:53:02AM +0000, David Howells wrote:
> KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> 
> > David, Could you please try following patch if you have NOMMU machine?
> > it is straightforward porting to nommu.
> 
> Is this patch actually sufficient, though?  Surely it requires an alteration
> to ramfs to mark the page as being unevictable?

ramfs already marks the whole address space of each inode as
unevictable, see ramfs_get_inode().

The reclaim code will regard this when the config option is enabled.

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
