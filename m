Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id D3654900138
	for <linux-mm@kvack.org>; Fri, 26 Aug 2011 14:25:26 -0400 (EDT)
Date: Fri, 26 Aug 2011 14:25:22 -0400
From: Dave Jones <davej@redhat.com>
Subject: Re: VM: add would_have_oomkilled sysctl
Message-ID: <20110826182522.GB2720@redhat.com>
References: <20110826161422.GB30573@redhat.com>
 <alpine.DEB.2.00.1108261117550.13943@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1108261117550.13943@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Fri, Aug 26, 2011 at 11:21:20AM -0700, David Rientjes wrote:
 > On Fri, 26 Aug 2011, Dave Jones wrote:
 > 
 > > At various times in the past, we've had reports where users have been
 > > convinced that the oomkiller was too heavy handed. I added this sysctl
 > > mostly as a knob for them to see that the kernel really doesn't do much better
 > > without killing something.
 > > 
 > 
 > The page allocator expects that the oom killer will kill something to free 
 > memory so it takes a temporary timeout and then retries the allocation 
 > indefinitely.  We never oom kill unless we are going to retry 
 > indefinitely, otherwise it wouldn't be worthwhile.
 > 
 > That said, the only time the oom killer doesn't actually do something is 
 > when it detects an exiting thread that will hopefully free memory soon or 
 > when it detects an eligible thread that has already been oom killed and 
 > we're waiting for it to exit.  So this patch will result in an endless 
 > series of unratelimited printk's.
 > 
 > Not sure that's very helpful.

It's an old patch, and the oom-killer heuristics have improved since then,
as this didn't used to be the case.  Regardless, I'll just drop it from Fedora.

thanks,

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
