Message-ID: <402128D0.2020509@tmr.com>
Date: Wed, 04 Feb 2004 12:16:00 -0500
From: Bill Davidsen <davidsen@tmr.com>
MIME-Version: 1.0
Subject: Re: VM patches (please review)
References: <402065DE.9090902@cyberone.com.au>
In-Reply-To: <402065DE.9090902@cyberone.com.au>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <piggin@cyberone.com.au>
Cc: Andrew Morton <akpm@osdl.org>, Andrea Arcangeli <andrea@suse.de>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:
> http://www.kerneltrap.org/~npiggin/vm/
> (may need to reload)
> 
> Here are the patches to go with my earlier post.
> kernel is 2.6.2-rc3-mm1.
> 
> I'm suire I've upset at least one uncommented^Wdivine
> balance so if anyone has time to review and comment
> it would be appreciated.
> 
> I can email the patches to the lists if anyone would
> like?

Since this is broken down nicely, a line or two about what each patch 
does or doesn't address would be useful. In particular, having just 
gotten a working RSS I'm suspicious of the patch named vm-no-rss-limit 
being desirable ;-)

Nice work, but it would be nice to see what problem a patch addresses to 
check for blowback under some other load.


-- 
bill davidsen <davidsen@tmr.com>
   CTO TMR Associates, Inc
   Doing interesting things with small computers since 1979
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
