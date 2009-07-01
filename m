Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 210796B004F
	for <linux-mm@kvack.org>; Tue, 30 Jun 2009 22:55:58 -0400 (EDT)
Message-ID: <4A4AD07E.2040508@redhat.com>
Date: Tue, 30 Jun 2009 22:57:02 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: Found the commit that causes the OOMs
References: <20090701021645.GA6356@localhost> <20090701022644.GA7510@localhost> <20090701114959.85D3.A69D9226@jp.fujitsu.com>
In-Reply-To: <20090701114959.85D3.A69D9226@jp.fujitsu.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Wu Fengguang <fengguang.wu@gmail.com>, David Woodhouse <dwmw2@infradead.org>, David Howells <dhowells@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux-foundation.org>, "peterz@infradead.org" <peterz@infradead.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>, "Barnes, Jesse" <jesse.barnes@intel.com>
List-ID: <linux-mm.kvack.org>

KOSAKI Motohiro wrote:

>> [ 1522.019259] Active_anon:11 active_file:6 inactive_anon:0
>> [ 1522.019260]  inactive_file:0 unevictable:0 dirty:0 writeback:0 unstable:0
>> [ 1522.019261]  free:1985 slab:44399 mapped:132 pagetables:61830 bounce:0
>> [ 1522.019262]  isolate:69817
> 
> OK. thanks.
> I plan to submit this patch after small more tests. it is useful for OOM analysis.

It is also useful for throttling page reclaim.

If more than half of the inactive pages in a zone are
isolated, we are probably beyond the point where adding
additional reclaim processes will do more harm than good.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
