Date: Fri, 21 Jan 2000 14:34:14 +0100 (CET)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: [PATCH] 2.2.14 VM fix #3
In-Reply-To: <Pine.LNX.4.10.10001210425250.27593-100000@mirkwood.dummy.home>
Message-ID: <Pine.LNX.4.21.0001211425210.486-100000@alpha.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@nl.linux.org>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

On Fri, 21 Jan 2000, Rik van Riel wrote:

>Hi Alan, Andrea,
>
>here is my 3rd patch for the VM troubles. It has merged
>parts of Andrea's patch with my patch and does some extra
>improvements.

Sorry but I will never agree with your patch. The GFP_KERNEL change is not
something for 2.2.x. We have major deadlocks in getblk for example and you
may trigger tham more easily forbidding GFP_MID allocations to succeed. I
don't really see why you do these changes. What problem do you had on your
machine related to that? Such change sure won't help atomic allocations. Your
change only make a difference if we are oom.

Also killing the low_on_memory will harm performance. You doesn't seems to
see what such bit (that should be a per-process thing) is good for.

And the 1-second polling loop has to be killed since it make no sense.

>- below freepages.low, kswapd is immediately woken up,

Yes, using freepages.low is way better than my original freepages.high. I
noticed that this night after posting the patch. Anyway it's a
performance-only issue (see my other email) where I am providing an
incremental patch and a new version of my patch.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
