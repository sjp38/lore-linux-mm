From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 0/3] make mapped executable pages the first class citizen (with test cases)
Date: Mon, 08 Jun 2009 17:10:44 +0800
Message-ID: <20090608091044.880249722@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 6B3D46B004D
	for <linux-mm@kvack.org>; Mon,  8 Jun 2009 04:06:27 -0400 (EDT)
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "Wu, Fengguang" <fengguang.wu@intel.com>, Andi Kleen <andi@firstfloor.org>, Christoph Lameter <cl@linux-foundation.org>, Elladan <elladan@eskimo.com>, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>
List-Id: linux-mm.kvack.org

Andrew,

I managed to back this patchset with two test cases :)

They demonstrated that
- X desktop responsiveness can be *doubled* under high memory/swap pressure
- it can almost stop major faults when the active file list is slowly scanned
  because of undergoing partially cache hot streaming IO

The details are included in the changelog.

Thanks,
Fengguang
-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
