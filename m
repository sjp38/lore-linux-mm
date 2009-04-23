Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 33BE16B009F
	for <linux-mm@kvack.org>; Thu, 23 Apr 2009 19:13:22 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id C515482C22D
	for <linux-mm@kvack.org>; Thu, 23 Apr 2009 19:24:08 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id RQP9gbxoksq9 for <linux-mm@kvack.org>;
	Thu, 23 Apr 2009 19:24:04 -0400 (EDT)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 80D2582C24B
	for <linux-mm@kvack.org>; Thu, 23 Apr 2009 19:23:59 -0400 (EDT)
Date: Thu, 23 Apr 2009 19:04:20 -0400 (EDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 19/22] Update NR_FREE_PAGES only as necessary
In-Reply-To: <20090423160610.a093ddf0.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.1.10.0904231903230.26300@qirst.com>
References: <1240408407-21848-1-git-send-email-mel@csn.ul.ie> <1240408407-21848-20-git-send-email-mel@csn.ul.ie> <20090423160610.a093ddf0.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, kosaki.motohiro@jp.fujitsu.com, npiggin@suse.de, linux-kernel@vger.kernel.org, ming.m.lin@intel.com, yanmin_zhang@linux.intel.com, peterz@infradead.org, penberg@cs.helsinki.fi
List-ID: <linux-mm.kvack.org>

On Thu, 23 Apr 2009, Andrew Morton wrote:

> If not, what _is_ it asserting?

That the alignment of an order N page in the max order block is proper?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
