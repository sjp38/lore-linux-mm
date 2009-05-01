Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id AA0C66B003D
	for <linux-mm@kvack.org>; Thu, 30 Apr 2009 21:17:41 -0400 (EDT)
Date: Thu, 30 Apr 2009 18:13:40 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] vmscan: evict use-once pages first (v2)
Message-Id: <20090430181340.6f07421d.akpm@linux-foundation.org>
In-Reply-To: <20090430205936.0f8b29fc@riellaptop.surriel.com>
References: <20090428044426.GA5035@eskimo.com>
	<20090428192907.556f3a34@bree.surriel.com>
	<1240987349.4512.18.camel@laptop>
	<20090429114708.66114c03@cuia.bos.redhat.com>
	<20090430072057.GA4663@eskimo.com>
	<20090430174536.d0f438dd.akpm@linux-foundation.org>
	<20090430205936.0f8b29fc@riellaptop.surriel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: elladan@eskimo.com, peterz@infradead.org, linux-kernel@vger.kernel.org, tytso@mit.edu, kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 30 Apr 2009 20:59:36 -0400
Rik van Riel <riel@redhat.com> wrote:

> On Thu, 30 Apr 2009 17:45:36 -0700
> Andrew Morton <akpm@linux-foundation.org> wrote:
> 
> > Were you able to tell whether altering /proc/sys/vm/swappiness
> > appropriately regulated the rate at which the mapped page count
> > decreased?
> 
> That should not make a difference at all for mapped file
> pages, after the change was merged that makes the VM ignores
> the referenced bit of mapped active file pages.
> 
> Ever since the split LRU code was merged, all that the
> swappiness controls is the aggressiveness of file vs
> anonymous LRU scanning.

Which would cause exactly the problem Elladan saw?

> Currently the kernel has no effective code to protect the 
> page cache working set from streaming IO.  Elladan's bug
> report shows that we do need some kind of protection...

Seems to me that reclaim should treat swapcache-backed mapped mages in
a similar fashion to file-backed mapped pages?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
