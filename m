Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 462FB6B00A3
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 12:25:03 -0400 (EDT)
Message-ID: <4A5F5454.8070300@redhat.com>
Date: Thu, 16 Jul 2009 12:24:52 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: count only reclaimable lru pages
References: <20090716133454.GA20550@localhost> <4987.1247760908@redhat.com>
In-Reply-To: <4987.1247760908@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Howells <dhowells@redhat.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux-foundation.org>, "peterz@infradead.org" <peterz@infradead.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>, "Barnes, Jesse" <jesse.barnes@intel.com>
List-ID: <linux-mm.kvack.org>

David Howells wrote:
> Wu Fengguang <fengguang.wu@intel.com> wrote:
> 
>> It can greatly (and correctly) increase the slab scan rate under high memory
>> pressure (when most file pages have been reclaimed and swap is full/absent),
>> thus avoid possible false OOM kills.
> 
> I applied this to my test machine's kernel and rebooted.  It hit the OOM
> killer a few seconds after starting msgctl11 .  Furthermore, it was not then
> responsive to SysRq+b or anything else and had to have the magic button
> pushed.

It's part of a series of patches, including the three
posted by Kosaki-san last night (to track the number
of isolated pages) and the patch I posted last night
(to throttle reclaim when too many pages are isolated).

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
