Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id KAA27634
	for <linux-mm@kvack.org>; Wed, 7 Apr 1999 10:04:39 -0400
Date: Wed, 7 Apr 1999 15:49:34 +0200 (CEST)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: [patch] only-one-cache-query [was Re: [patch] arca-vm-2.2.5]
In-Reply-To: <14091.22597.198249.259683@dukat.scot.redhat.com>
Message-ID: <Pine.LNX.4.05.9904071544200.469-100000@laser.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Mark Hemment <markhe@sco.COM>, Chuck Lever <cel@monkey.org>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

On Wed, 7 Apr 1999, Stephen C. Tweedie wrote:

>At that point, we will need to drop any spinlocks we hold before calling
>get_free_page(), because the scheduler will only drop the global lock
>automatically if we sleep and we can't sleep with any other locks held.
>Now, even if we _don't_ sleep, another CPU can get in to mess with the
>page cache while we are doing allocation stuff.

Yes, agreed.

Andrea Arcangeli

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
