Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id QAA20405
	for <linux-mm@kvack.org>; Thu, 22 Oct 1998 16:10:42 -0400
Date: Thu, 22 Oct 1998 22:03:51 +0200 (CEST)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: swap/memory patches
In-Reply-To: <19981022210251.A948@kg1.ping.de>
Message-ID: <Pine.LNX.3.96.981022214651.12636B-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Kurt Garloff <garloff@kg1.ping.de>
Cc: Linux kernel list <linux-kernel@vger.rutgers.edu>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 22 Oct 1998, Kurt Garloff wrote:

> There have been quite some patches on MM/swap/OOM of Linux by you,
> Andrea and Stephen during the last time. Is there a final version?
> Are there recent (2.1.125+) patches for these problems? Did anything
> get into the kernel? 

There are no final versions and nothing got into the kernel.
Personally, I think Andrea's patch (minus the kswapd early
give-up) should go into the kernel now.

My part of the patch (OOM killing when kswapd can't cope
any more _and_ we're really out of memory) is running
well at a lot of people's places, but it really is an added
feature and we're in feature freeze right now.

This feature freeze means that I'm not going to drive Linus
crazy in order to include a feature, not even if 100 sysadmins
have asked me to. If you really really want it in you'll either
have to drive Linus crazy yourself or you'll have to apply the
patch to the kernel yourself -- I will make sure that it's
available...

> What I have in mind, when writing these lines, is:
> (1) cow-swapin: I often observed that after compiling a large C++ program
>     (which needs some swap), the shell keeps swapping something in on every
>     <Enter> keypress. This is cured by swapoff -a; swapon -a.
>     If I correctly understood, this is what cow-swapin was supposed to cure.

Wasn't this fixed -- Andrea, Stephen?

> (2) somebody claimed having found swap bugs
> (3) better oom behaviour
> 
> I consider (1) to be a serious bug. I don't know much about (2). (3) is
> obviously hard to solve cleanly.

Several people are running with my solution to (3)
in their kernel and have reported that it kills the
right task 9 out of 10 times. This indicates that
my patch is working rather good...

Rik.
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
