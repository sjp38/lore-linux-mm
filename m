Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id KAA27805
	for <linux-mm@kvack.org>; Wed, 7 Apr 1999 10:13:16 -0400
Date: Wed, 7 Apr 1999 16:08:31 +0200 (CEST)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: [patch] only-one-cache-query [was Re: [patch] arca-vm-2.2.5]
In-Reply-To: <Pine.LNX.3.96.990407154601.30376E-100000@chiara.csoma.elte.hu>
Message-ID: <Pine.LNX.4.05.9904071606150.357-100000@laser.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@chiara.csoma.elte.hu>
Cc: Mark Hemment <markhe@sco.COM>, Chuck Lever <cel@monkey.org>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, Linus Torvalds <torvalds@transmeta.com>, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

On Wed, 7 Apr 1999, Ingo Molnar wrote:

>this can be done via an existing variable, kstat.ctxsw, no need to add yet
>another 'have we scheduled' flag. But the whole approach is quite flawed

I just thought about ctxsw but kstat.context_swtch could be not increased
(if next == prev), and if we release the lock we must return finding the
page.

Andrea Arcangeli

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
