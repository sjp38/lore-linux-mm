Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id CF8016B0088
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 10:43:14 -0400 (EDT)
Message-ID: <4A5F3C70.7010001@redhat.com>
Date: Thu, 16 Jul 2009 10:42:56 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: count only reclaimable lru pages
References: <20090716133454.GA20550@localhost>  <alpine.DEB.1.10.0907160959260.32382@gentwo.org>  <20090716142533.GA27165@localhost> <1247754491.6586.23.camel@laptop> <alpine.DEB.1.10.0907161037590.7930@gentwo.org>
In-Reply-To: <alpine.DEB.1.10.0907161037590.7930@gentwo.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, David Howells <dhowells@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>, "Barnes, Jesse" <jesse.barnes@intel.com>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Thu, 16 Jul 2009, Peter Zijlstra wrote:
> 
>>> What would you suggest?  In fact I'm not totally comfortable with it.
>>> Maybe it would be safer to simply stick with the old _lru_pages
>>> naming?
>> Nah, I like the reclaimable name, these pages are at least potentially
>> reclaimable.
>>
>> lru_pages() is definately not correct anymore since you exclude the
>> unevictable and possibly the anon pages.
> 
> Well lets at least add a comment at the beginning of the functions
> explaining that these are potentially reclaimable and list some of the
> types of pages that may not be reclaimable.

The pages that are not reclaimable will be on the
unevictable LRU list, not on the lists we count.

The only case of pages not being evictable is the
anon pages, once swap fills up.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
