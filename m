Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id LAA11336
	for <linux-mm@kvack.org>; Sat, 19 Dec 1998 11:19:03 -0500
Date: Sat, 19 Dec 1998 16:17:55 GMT
Message-Id: <199812191617.QAA00819@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: PG_clean for shared mapping smart syncing
In-Reply-To: <Pine.LNX.3.96.981219165802.208A-100000@laser.bogus>
References: <Pine.LNX.3.96.981219165802.208A-100000@laser.bogus>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@e-mind.com>
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, "Stephen C. Tweedie" <sct@redhat.com>, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Sat, 19 Dec 1998 17:04:26 +0100 (CET), Andrea Arcangeli
<andrea@e-mind.com> said:

Just a couple of comments: I can't see any mechanism in this patch for
clearing other process's pte dirty bits when we sync a shared page (I
know you had a patch for this before), and conceptually I much prefer
to have a Dirty bit than a Clean bit, simply because that's what we
use absolutely everywhere else in the kernel.

--Stephen
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
