Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 031786B00BB
	for <linux-mm@kvack.org>; Tue, 13 Oct 2009 04:04:06 -0400 (EDT)
Date: Tue, 13 Oct 2009 16:03:55 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH][BUGFIX] vmscan: limit VM_EXEC protection to file pages
Message-ID: <20091013080355.GA20927@localhost>
References: <200910122244.19666.borntraeger@de.ibm.com> <20091013022650.GB7345@localhost> <4AD3E6C4.805@redhat.com> <20091013080054.GA20395@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091013080054.GA20395@localhost>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, stable@kernel.org
Cc: Rik van Riel <riel@redhat.com>, Christian Borntraeger <borntraeger@de.ibm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Elladan <elladan@eskimo.com>, Nick Piggin <npiggin@suse.de>, Andi Kleen <andi@firstfloor.org>, Christoph Lameter <cl@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>


This bug fix applies to both 2.6.31 and 2.6.32.

Christoph did the hard work of catching/testing it, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
