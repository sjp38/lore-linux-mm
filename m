Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 899176B0206
	for <linux-mm@kvack.org>; Wed, 24 Mar 2010 17:57:42 -0400 (EDT)
Date: Wed, 24 Mar 2010 22:57:29 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 07/11] Memory compaction core
Message-ID: <20100324215729.GM10659@random.random>
References: <1269347146-7461-1-git-send-email-mel@csn.ul.ie>
 <1269347146-7461-8-git-send-email-mel@csn.ul.ie>
 <20100324133347.9b4b2789.akpm@linux-foundation.org>
 <20100324145946.372f3f31@bike.lwn.net>
 <20100324211924.GH10659@random.random>
 <20100324152854.48f72171@bike.lwn.net>
 <20100324214742.GL10659@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100324214742.GL10659@random.random>
Sender: owner-linux-mm@kvack.org
To: Jonathan Corbet <corbet@lwn.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 24, 2010 at 10:47:42PM +0100, Andrea Arcangeli wrote:
> As far as I can tell, VM_BUG_ON would make _zero_ differences there.
> 
> I think you mistaken a VM_BUG_ON for a:
> 
>   if (could_be_null->something) {

Ooops, I wrote ->something to indicate that "could_be_null" was going
to later be dereferenced for ->something and here we're checking if it
could be null when we dereference something, but now I think it could
be very confusing as I use strict C for all the rest, so maybe I
should clarify in C it would be !could_be_null.

>      WARN_ON(1);
>      return -ESOMETHING;
>   }
> 
> adding a VM_BUG_ON(inode->something) would _still_ be as exploitable

here the same !inode.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
