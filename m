Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id CB68A6B00B1
	for <linux-mm@kvack.org>; Mon, 23 Feb 2009 09:48:30 -0500 (EST)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 2C08882C2FF
	for <linux-mm@kvack.org>; Mon, 23 Feb 2009 09:53:01 -0500 (EST)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 6NAKLqxr0OUK for <linux-mm@kvack.org>;
	Mon, 23 Feb 2009 09:53:01 -0500 (EST)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 0B1E482C304
	for <linux-mm@kvack.org>; Mon, 23 Feb 2009 09:52:38 -0500 (EST)
Date: Mon, 23 Feb 2009 09:38:58 -0500 (EST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [RFC PATCH 00/20] Cleanup and optimise the page allocator
In-Reply-To: <1235344649-18265-1-git-send-email-mel@csn.ul.ie>
Message-ID: <alpine.DEB.1.10.0902230934360.7298@qirst.com>
References: <1235344649-18265-1-git-send-email-mel@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>
List-ID: <linux-mm.kvack.org>

On Sun, 22 Feb 2009, Mel Gorman wrote:

> I haven't run a page-allocator micro-benchmark to see what sort of figures
> that gives. Christoph, I recall you had some sort of page allocator
> micro-benchmark. Do you want to give it a shot or remind me how to use
> it please?

The page allocator / slab allocator microbenchmarks are in my VM
development git tree. The branch is named tests.

http://git.kernel.org/?p=linux/kernel/git/christoph/vm.git;a=shortlog;h=tests


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
