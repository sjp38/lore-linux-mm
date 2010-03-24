Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id B1B046B01FA
	for <linux-mm@kvack.org>; Wed, 24 Mar 2010 16:59:50 -0400 (EDT)
Date: Wed, 24 Mar 2010 14:59:46 -0600
From: Jonathan Corbet <corbet@lwn.net>
Subject: Re: [PATCH 07/11] Memory compaction core
Message-ID: <20100324145946.372f3f31@bike.lwn.net>
In-Reply-To: <20100324133347.9b4b2789.akpm@linux-foundation.org>
References: <1269347146-7461-1-git-send-email-mel@csn.ul.ie>
	<1269347146-7461-8-git-send-email-mel@csn.ul.ie>
	<20100324133347.9b4b2789.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 24 Mar 2010 13:33:47 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> > +	VM_BUG_ON(cc == NULL);  
> 
> It's a bit strange to test this when we're about to oops anyway.  The
> oops will tell us the same thing.

...except that we've seen a fair number of null pointer dereference
exploits that have told us something altogether different.  Are we
*sure* we don't want to test for null pointers...?

jon

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
