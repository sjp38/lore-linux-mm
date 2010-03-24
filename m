Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 61C1F6B01FF
	for <linux-mm@kvack.org>; Wed, 24 Mar 2010 17:15:13 -0400 (EDT)
Date: Wed, 24 Mar 2010 14:14:00 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 07/11] Memory compaction core
Message-Id: <20100324141400.72479ce6.akpm@linux-foundation.org>
In-Reply-To: <20100324145946.372f3f31@bike.lwn.net>
References: <1269347146-7461-1-git-send-email-mel@csn.ul.ie>
	<1269347146-7461-8-git-send-email-mel@csn.ul.ie>
	<20100324133347.9b4b2789.akpm@linux-foundation.org>
	<20100324145946.372f3f31@bike.lwn.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Jonathan Corbet <corbet@lwn.net>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 24 Mar 2010 14:59:46 -0600
Jonathan Corbet <corbet@lwn.net> wrote:

> On Wed, 24 Mar 2010 13:33:47 -0700
> Andrew Morton <akpm@linux-foundation.org> wrote:
> 
> > > +	VM_BUG_ON(cc == NULL);  
> > 
> > It's a bit strange to test this when we're about to oops anyway.  The
> > oops will tell us the same thing.
> 
> ...except that we've seen a fair number of null pointer dereference
> exploits that have told us something altogether different.  Are we
> *sure* we don't want to test for null pointers...?
> 

It's hard to see what the test gains us really - the kernel has
zillions of pointer derefs, any of which could be NULL if we have a
bug.  Are we more likely to have a bug here than elsewhere?

This one will oops on a plain old read, so it's a bit moot in this
case.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
