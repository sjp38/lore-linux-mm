Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id DF0CE6B004D
	for <linux-mm@kvack.org>; Mon, 18 May 2009 10:57:49 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 8B38D82C410
	for <linux-mm@kvack.org>; Mon, 18 May 2009 11:11:53 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id A-6hokWtHHa8 for <linux-mm@kvack.org>;
	Mon, 18 May 2009 11:11:48 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id E11CC82C332
	for <linux-mm@kvack.org>; Mon, 18 May 2009 11:11:48 -0400 (EDT)
Date: Mon, 18 May 2009 10:46:15 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 2/3] vmscan: make mapped executable pages the first class
 citizen
In-Reply-To: <20090516092858.GA12104@localhost>
Message-ID: <alpine.DEB.1.10.0905181045340.20244@qirst.com>
References: <20090516090005.916779788@intel.com> <20090516090448.410032840@intel.com> <20090516092858.GA12104@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Elladan <elladan@eskimo.com>, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

On Sat, 16 May 2009, Wu Fengguang wrote:

> vmscan: make mapped executable pages the first class citizen

Nice description! Can you also add the results of a test that shows the
benefit of this patch?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
