Message-ID: <45D4DF28.7070409@redhat.com>
Date: Thu, 15 Feb 2007 17:31:04 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC] Remove unswappable anonymous pages off the LRU
References: <Pine.LNX.4.64.0702151300500.31366@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0702151300500.31366@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Nick Piggin <nickpiggin@yahoo.com.au>, Peter Zijlstra <a.p.zijlstra@chello.nl>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Martin J. Bligh" <mbligh@mbligh.org>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> If we do not have any swap or we have run out of swap then anonymous pages
> can no longer be removed from memory. In that case we simply treat them
> like mlocked pages.

Running out of swap is a temporary condition.
You need to have some way for those pages to
make it back onto the LRU list when swap
becomes available.

Better yet, we could implement a better way to
reclaim swap space, or reclaim swap space in a
different part of the code.

For example, we could try to reclaim the swap
space of every page that we scan on the active
list - when swap space starts getting tight.

-- 
All Rights Reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
