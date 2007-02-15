Message-ID: <45D4E3B6.8050009@redhat.com>
Date: Thu, 15 Feb 2007 17:50:30 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC] Remove unswappable anonymous pages off the LRU
References: <Pine.LNX.4.64.0702151300500.31366@schroedinger.engr.sgi.com> <45D4DF28.7070409@redhat.com> <Pine.LNX.4.64.0702151439520.32026@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0702151439520.32026@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Nick Piggin <nickpiggin@yahoo.com.au>, Peter Zijlstra <a.p.zijlstra@chello.nl>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Martin J. Bligh" <mbligh@mbligh.org>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Thu, 15 Feb 2007, Rik van Riel wrote:
> 
>> Running out of swap is a temporary condition.
>> You need to have some way for those pages to
>> make it back onto the LRU list when swap
>> becomes available.
> 
> Yup any ideas how?

Not really.

>> For example, we could try to reclaim the swap
>> space of every page that we scan on the active
>> list - when swap space starts getting tight.
> 
> Good idea.

I suspect this will be a better approach.  That way
the least used pages can cycle into swap space, and
the more used pages can be in RAM.

The only reason pages are unswappable when we run
out of swap is that we don't free up the swap space
used by pages that are in memory.

-- 
All Rights Reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
