Subject: RE: [patch] vmsig: notify user applications of virtual memory
	events via real-time signals
From: Rohit Seth <rohit.seth@intel.com>
In-Reply-To: <B061F5ED2860D9439AE34EE5C141938C090CDE@zor.ads.cs.umass.edu>
References: <B061F5ED2860D9439AE34EE5C141938C090CDE@zor.ads.cs.umass.edu>
Content-Type: text/plain
Date: Tue, 22 Nov 2005 18:29:51 -0800
Message-Id: <1132712991.12897.8.camel@akash.sc.intel.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Emery Berger <emery@cs.umass.edu>
Cc: Rik van Riel <riel@redhat.com>, Yi Feng <yifeng@cs.umass.edu>, linux-mm@kvack.org, Andrew Morton <akpm@osdl.org>, Matthew Hertz <hertzm@canisius.edu>
List-ID: <linux-mm.kvack.org>

On Tue, 2005-11-22 at 13:53 -0800, Emery Berger wrote:
> > That seems pretty high overhead.  I wonder if it wouldn't work
> > similarly well for the kernel to simply notify the registrered
> > apps that memory is running low and they should garbage collect
> > _something_, without caring which pages.
> 
> Actually, it's quite important that the application know exactly which
> page is being evicted, in order that it be "bookmarked". We found that
> this particular aspect of the garbage collection algorithm was crucial
> (it's in the paper).
> 
Seems like a good idea for the notifications.

But for it to be useful for low memory conditions, I think it will
better if kernel knew (at possibly direct reclaim time) to swap out the
specific pages...so as to make it more cooperative between user and
kernel.  If kernel has to first notify user app (and possibly thousands
of them) that it is looking for free pages then it will probably be too
late or too expensive before an application actually completes the
operation of freeing the pages. 

-rohit

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
