Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id TAA00136
	for <linux-mm@kvack.org>; Thu, 7 Jan 1999 19:04:14 -0500
Date: Fri, 8 Jan 1999 01:04:19 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: arca-vm-8 [Re: [patch] arca-vm-6, killed kswapd [Re: [patch] new-vm , improvement , [Re: 2.2.0 Bug summary]]]
In-Reply-To: <Pine.LNX.3.95.990107154908.5025Q-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.3.96.990108010000.1816A-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 7 Jan 1999, Linus Torvalds wrote:

> Ehh, and how do you protect against somebody playing games with your mind
> by doing _huge_ mappings of something that takes no real memory? The VM
> footprint of a process is not necessarily related to how much physical
> memory you use. 

I was infact rejecting from the total_vm calc all tasks with a rss == 0,
but yes, I am convinced that my more fine grined counter is not needed.

Andrea Arcangeli

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
