Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id C66128D0039
	for <linux-mm@kvack.org>; Thu, 24 Feb 2011 10:15:56 -0500 (EST)
Subject: Re: [Bug 29772] New: memory compaction crashed
From: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <20110224150605.GX15652@csn.ul.ie>
References: <bug-29772-27@https.bugzilla.kernel.org/>
	 <20110223134015.be96110b.akpm@linux-foundation.org>
	 <20110223233934.GN15652@csn.ul.ie>
	 <1298537237.3764.17.camel@jlt3.sipsolutions.net>
	 <20110224103706.GR15652@csn.ul.ie>
	 <1298546750.3764.23.camel@jlt3.sipsolutions.net>
	 <20110224150605.GX15652@csn.ul.ie>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 24 Feb 2011 16:14:21 +0100
Message-ID: <1298560461.4251.2.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org

On Thu, 2011-02-24 at 15:06 +0000, Mel Gorman wrote:

> > Possible. I had some graphics issues with X hanging once a while, but
> > with all of those I could still ssh in and reboot the machine.
> 
> It could very well be related with the main difference being that
> compaction blew up with interrupts disabled taking down the whole
> machine. Have you a reproduction case for the X hangs?

No, I don't, it just seems to happen every couple of hours. It just
happened again while I wasn't even touching the laptop (was reading
something else)...

> It might also be worth running memtest on the machine just in case but I
> find it doubtful that it's the problem. A buggy graphics driver feels
> more likely. Are you running anything like compiz? If yes, are the
> hangs still reproducible with it disabled?

No, I'm not running compiz or any other composition manager.

> Thanks. With luck, it'll show up a driver that is corrupting memory.

Well, it hung a minute ago, but I couldn't even ssh in any more...
Sometimes I can, sometimes I can't.

> Ok, good to know. Right now I am leaning towards a buggy graphics driver
> or X server is corrupting memory and compaction suffered particularly
> badly from it.

Yeah, I'm inclined to agree.

Thanks for your help. Can we copy the bug to some DRI folks maybe?

johannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
