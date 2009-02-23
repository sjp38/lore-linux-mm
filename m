Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 03E636B00B1
	for <linux-mm@kvack.org>; Sun, 22 Feb 2009 19:04:36 -0500 (EST)
Subject: Re: [RFC PATCH 00/20] Cleanup and optimise the page allocator
From: Andi Kleen <andi@firstfloor.org>
References: <1235344649-18265-1-git-send-email-mel@csn.ul.ie>
Date: Mon, 23 Feb 2009 01:02:59 +0100
In-Reply-To: <1235344649-18265-1-git-send-email-mel@csn.ul.ie> (Mel Gorman's message of "Sun, 22 Feb 2009 23:17:09 +0000")
Message-ID: <87ljryuij0.fsf@basil.nowhere.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>
List-ID: <linux-mm.kvack.org>

Mel Gorman <mel@csn.ul.ie> writes:


BTW one additional tuning opportunity would be to change cpusets to
always precompute zonelists out of line and then avoid doing
all these checks in the fast path.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
