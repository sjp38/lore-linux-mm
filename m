Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 7B9FF6B004F
	for <linux-mm@kvack.org>; Wed,  5 Aug 2009 10:53:32 -0400 (EDT)
Subject: Re: [PATCH 4/4] tracing, page-allocator: Add a postprocessing
	script for page-allocator-related ftrace events
From: Larry Woodman <lwoodman@redhat.com>
In-Reply-To: <20090804204857.GA32092@csn.ul.ie>
References: <1249409546-6343-1-git-send-email-mel@csn.ul.ie>
	 <1249409546-6343-5-git-send-email-mel@csn.ul.ie>
	 <20090804112246.4e6d0ab1.akpm@linux-foundation.org>
	 <4A787D84.2030207@redhat.com>
	 <20090804121332.46df33a7.akpm@linux-foundation.org>
	 <20090804204857.GA32092@csn.ul.ie>
Content-Type: text/plain
Date: Wed, 05 Aug 2009 10:53:50 -0400
Message-Id: <1249484030.7512.42.camel@dhcp-100-19-198.bos.redhat.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, mingo@elte.hu, peterz@infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2009-08-04 at 21:48 +0100, Mel Gorman wrote:

> > 
> 
> Adding and deleting tracepoints, rebuilding and rebooting the kernel is
> obviously usable by developers but not a whole pile of use if
> recompiling the kernel is not an option or you're trying to debug a
> difficult-to-reproduce-but-is-happening-now type of problem.
> 
> Of the CC list, I believe Larry Woodman has the most experience with
> these sort of problems in the field so I'm hoping he'll make some sort
> of comment.
> 

I am all for adding tracepoints that eliminate the need to locate a
problem, add debug code, rebuild, reboot and retest until the real
problem is found.  

Personally I have not seen as many problems in the page allocator as I
have in the page reclaim code thats why the majority of my tracepoints
were in vmscan.c  However I do ACK this patch set because it provides
the opportunity to zoom into the page allocator dynamically without
needing to iterate through the cumbersome debug process.

Larry
 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
