Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id MAA25132
	for <linux-mm@kvack.org>; Fri, 23 Oct 1998 12:46:38 -0400
Date: Fri, 23 Oct 1998 12:20:40 +0200 (CEST)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: swap/memory patches
In-Reply-To: <Pine.LNX.3.96.981022214651.12636B-100000@mirkwood.dummy.home>
Message-ID: <Pine.LNX.3.96.981023121950.1238B-100000@dragon.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Cc: Kurt Garloff <garloff@kg1.ping.de>, Linux kernel list <linux-kernel@vger.rutgers.edu>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 22 Oct 1998, Rik van Riel wrote:

>> (1) cow-swapin: I often observed that after compiling a large C++ program
>>     (which needs some swap), the shell keeps swapping something in on every
>>     <Enter> keypress. This is cured by swapoff -a; swapon -a.
>>     If I correctly understood, this is what cow-swapin was supposed to cure.
>
>Wasn't this fixed -- Andrea, Stephen?

Just fixed in Linus's tree.

Andrea Arcangeli

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
