Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id C4EC66B0047
	for <linux-mm@kvack.org>; Sat,  6 Mar 2010 09:45:25 -0500 (EST)
Date: Sat, 6 Mar 2010 15:44:22 +0100
From: Christian Ehrhardt <uni@c--e.de>
Subject: Re: [PATCH] rmap: Fix Bugzilla Bug #5493
Message-ID: <20100306144422.GI17078@lisa.in-ulm.de>
References: <20100305093834.GG17078@lisa.in-ulm.de> <4B9110ED.5000703@redhat.com> <20100306010212.GH17078@lisa.in-ulm.de> <20100306020048.GA16967@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100306020048.GA16967@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Rik van Riel <riel@redhat.com>, Christian Ehrhardt <lk@c--e.de>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


Hi,

On Sat, Mar 06, 2010 at 03:00:48AM +0100, Johannes Weiner wrote:
> What's with expand_stack()?  This changes the radix index or the heap
> index, depending on the direction in which the stack grows, but it
> does not adjust the tree and so its order is violated.  Did you make
> sure that this is fine?

Ooops! Thanks for the hint. Not only expand stack but also vma_adjust
(aka vma_merge) need to update the tree, I guess.

However, it is somewhat odd that this did not trigger anything in
my tests. I guess I have to come up with a testcase that properly
checks this case.

      regards   Christian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
