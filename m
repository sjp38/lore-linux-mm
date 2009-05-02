Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 325CE6B003D
	for <linux-mm@kvack.org>; Sat,  2 May 2009 10:21:30 -0400 (EDT)
Message-ID: <49FC56EE.4080402@redhat.com>
Date: Sat, 02 May 2009 10:21:34 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] vmscan: don't export nr_saved_scan in /proc/zoneinfo
References: <200904302208.n3UM8t9R016687@imap1.linux-foundation.org> <20090501012212.GA5848@localhost> <20090430194907.82b31565.akpm@linux-foundation.org> <20090502023125.GA29674@localhost> <20090502024719.GA29730@localhost>
In-Reply-To: <20090502024719.GA29730@localhost>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "torvalds@linux-foundation.org" <torvalds@linux-foundation.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "lee.schermerhorn@hp.com" <lee.schermerhorn@hp.com>, "peterz@infradead.org" <peterz@infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Wu Fengguang wrote:
> The lru->nr_saved_scan's are not meaningful counters for even kernel
> developers.  They typically are smaller than 32 and are always 0 for
> large lists. So remove them from /proc/zoneinfo.
> 
> Hopefully this interface change won't break too many scripts.
> /proc/zoneinfo is too unstructured to be script friendly, and I wonder
> the affected scripts - if there are any - are still bleeding since the
> not long ago commit "vmscan: split LRU lists into anon & file sets",
> which also touched the "scanned" line :)
> 
> If we are to re-export accumulated vmscan counts in the future, they
> can go to new lines in /proc/zoneinfo instead of the current form, or
> to /sys/devices/system/node/node0/meminfo?
> 
> CC: Christoph Lameter <cl@linux-foundation.org>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
