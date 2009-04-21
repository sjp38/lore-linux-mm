Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 284C36B004D
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 11:16:46 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 3CA9682C6D2
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 11:27:24 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id Bd0p+8zRNK7w for <linux-mm@kvack.org>;
	Tue, 21 Apr 2009 11:27:24 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 17BBA82C6DA
	for <linux-mm@kvack.org>; Tue, 21 Apr 2009 11:27:18 -0400 (EDT)
Date: Tue, 21 Apr 2009 11:08:46 -0400 (EDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 24/25] Re-sort GFP flags and fix whitespace alignment
 for easier reading.
In-Reply-To: <20090421085229.GH12713@csn.ul.ie>
Message-ID: <alpine.DEB.1.10.0904211107250.19969@qirst.com>
References: <1240266011-11140-1-git-send-email-mel@csn.ul.ie> <1240266011-11140-25-git-send-email-mel@csn.ul.ie> <1240301043.771.56.camel@penberg-laptop> <20090421085229.GH12713@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Linux Memory Management List <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, 21 Apr 2009, Mel Gorman wrote:

> Hmm, doh. This resorted when another patch existed that no longer exists
> due to difficulties. This patch only fixes whitespace now but I didn't fix
> the changelog.  I can either move it to the next set altogether where it
> does resort things or drop it on the grounds whitespace patches just muck
> with changelogs. I'm leaning towards the latter.

Where were we with that other patch? I vaguely recalling reworking the
other patch (gfp_zone I believe) to be calculated at compile time. Did I
drop this?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
