Date: Tue, 7 Nov 2000 11:57:44 +0000
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: PATCH [2.4.0test10]: Kiobuf#02, fault-in fix
Message-ID: <20001107115744.E1384@redhat.com>
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
 
> I would _really_ want to see follow_page() just cleaned up altogether.
> 
> We should NOT have code that messes with combinations of
> "handle_mm_fault()" and "follow_page()" at all.

Is this a 2.5 cleanup or do you want things rearranged in the 2.4
bugfix too?

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
