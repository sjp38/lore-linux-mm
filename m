From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14452.54644.697386.175701@dukat.scot.redhat.com>
Date: Thu, 6 Jan 2000 17:48:36 +0000 (GMT)
Subject: Re: (reiserfs) Re: RFC: Re: journal ports for 2.3?
In-Reply-To: <386160CC.9F36DCE6@idiom.com>
References: <14430.51369.57387.224846@dukat.scot.redhat.com>
	<Pine.LNX.4.21.9912211056520.24670-100000@Fibonacci.suse.de>
	<14431.32449.832594.222614@dukat.scot.redhat.com>
	<386160CC.9F36DCE6@idiom.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hans Reiser <reiser@idiom.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Andrea Arcangeli <andrea@suse.de>, Chris Mason <clmsys@osfmail.isc.rit.edu>, reiserfs@devlinux.com, linux-fsdevel@vger.rutgers.edu, linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, 23 Dec 1999 02:37:48 +0300, Hans Reiser <reiser@idiom.com>
said:

>> > I completly agree to change mark_buffer_dirty() to call balance_dirty()
>> > before returning.

> How can we use a mark_buffer_dirty that calls balance_dirty in a
> place where we cannot call balance_dirty?

It shouldn't be impossible: as long as we are protected against
recursive invocations of balance_dirty (which should be easy to
arrange) we should be safe enough, at least if the memory reservation
bits of the VM/fs interaction are working so that the balance_dirty
can guarantee to run to completion.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.nl.linux.org/Linux-MM/
