Date: Wed, 4 Feb 2004 12:40:48 -0500 (EST)
From: Rik van Riel <riel@redhat.com>
Subject: Re: VM patches (please review)
In-Reply-To: <402128D0.2020509@tmr.com>
Message-ID: <Pine.LNX.4.44.0402041239311.24515-100000@chimarrao.boston.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Bill Davidsen <davidsen@tmr.com>
Cc: Nick Piggin <piggin@cyberone.com.au>, Andrew Morton <akpm@osdl.org>, Andrea Arcangeli <andrea@suse.de>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 4 Feb 2004, Bill Davidsen wrote:

> Since this is broken down nicely, a line or two about what each patch 
> does or doesn't address would be useful. In particular, having just 
> gotten a working RSS I'm suspicious of the patch named vm-no-rss-limit 
> being desirable ;-)

The bug with the RSS limit patch is that I forgot to
change the exec() code, so when init is exec()d it
gets an RSS limit of zero, which is inherited by all
its children --> always over the RSS limit, no page
aging, etc.

I need to find the cleanest way to add the inheriting
of RSS limit at exec time and send a patchlet for that
to akpm...

-- 
"Debugging is twice as hard as writing the code in the first place.
Therefore, if you write the code as cleverly as possible, you are,
by definition, not smart enough to debug it." - Brian W. Kernighan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
