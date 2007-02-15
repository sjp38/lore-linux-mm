Date: Thu, 15 Feb 2007 14:41:08 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC] Remove unswappable anonymous pages off the LRU
In-Reply-To: <45D4DF28.7070409@redhat.com>
Message-ID: <Pine.LNX.4.64.0702151439520.32026@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0702151300500.31366@schroedinger.engr.sgi.com>
 <45D4DF28.7070409@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Nick Piggin <nickpiggin@yahoo.com.au>, Peter Zijlstra <a.p.zijlstra@chello.nl>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Martin J. Bligh" <mbligh@mbligh.org>
List-ID: <linux-mm.kvack.org>

On Thu, 15 Feb 2007, Rik van Riel wrote:

> Running out of swap is a temporary condition.
> You need to have some way for those pages to
> make it back onto the LRU list when swap
> becomes available.

Yup any ideas how?
 
> Better yet, we could implement a better way to
> reclaim swap space, or reclaim swap space in a
> different part of the code.

Certainly an interesting project.
 
> For example, we could try to reclaim the swap
> space of every page that we scan on the active
> list - when swap space starts getting tight.

Good idea.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
