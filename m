Date: Wed, 8 Nov 2000 12:31:43 +0000
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: PATCH [2.4.0test10]: Kiobuf#02, fault-in fix
Message-ID: <20001108123143.O11411@redhat.com>
References: <20001106150539.A19112@redhat.com> <Pine.LNX.4.10.10011060912120.7955-100000@penguin.transmeta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.10.10011060912120.7955-100000@penguin.transmeta.com>; from torvalds@transmeta.com on Mon, Nov 06, 2000 at 09:23:38AM -0800
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Andrea Arcangeli <andrea@suse.de>, Rik van Riel <riel@nl.linux.org>, Ingo Molnar <mingo@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, Nov 06, 2000 at 09:23:38AM -0800, Linus Torvalds wrote:

> We should just change the page followers (do_no_page() and friends) to
> return the "struct page" directly, instead of returning an "int".

Even, as Andrea pointed out, if the cost is that we have to do two
extra atomic ops to bump the page count inside do_*_page and drop
it again in the fault handler?

I'll do it, but not if we later decide that the cost isn't worth it
and have to throw the code out.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
