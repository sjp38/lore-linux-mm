Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id LAA11414
	for <linux-mm@kvack.org>; Sat, 19 Dec 1998 11:27:24 -0500
Date: Sat, 19 Dec 1998 17:27:40 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: PG_clean for shared mapping smart syncing
In-Reply-To: <199812191617.QAA00819@dax.scot.redhat.com>
Message-ID: <Pine.LNX.3.96.981219172526.648A-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

On Sat, 19 Dec 1998, Stephen C. Tweedie wrote:

>Hi,
>
>On Sat, 19 Dec 1998 17:04:26 +0100 (CET), Andrea Arcangeli
><andrea@e-mind.com> said:
>
>Just a couple of comments: I can't see any mechanism in this patch for
>clearing other process's pte dirty bits when we sync a shared page (I

The only reason to add a bitflag in the page->flags field is to avoid
us to play with the pte. Now the pte is used only to set the page readonly
to allow us to remove the clean flag at the first page fault.

Andrea Arcangeli

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
