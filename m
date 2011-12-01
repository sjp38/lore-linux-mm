Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id F38D56B0055
	for <linux-mm@kvack.org>; Thu,  1 Dec 2011 05:29:10 -0500 (EST)
Date: Thu, 1 Dec 2011 11:29:04 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH] mm: Ensure that pfn_valid is called once per pageblock when
 reserving pageblocks
Message-ID: <20111201102904.GA8809@tiehlicka.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, Dang Bo <bdang@vmware.com>, Arve =?iso-8859-1?B?SGr4bm5lduVn?= <arve@android.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, John Stultz <john.stultz@linaro.org>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi,
the patch bellow fixes a crash during boot (when we set up reserved
page blocks) if zone start_pfn is not block aligned. The issue has
been introduced in 3.0-rc1 by 6d3163ce: mm: check if any page in a
pageblock is reserved before marking it MIGRATE_RESERVE.

I think this is 3.2 and stable material.
---
