Subject: Re: the new VMt
References: <Pine.LNX.4.21.0009251821170.9122-100000@elte.hu>
From: Jes Sorensen <jes@linuxcare.com>
Date: 26 Sep 2000 10:38:40 +0200
In-Reply-To: Ingo Molnar's message of "Mon, 25 Sep 2000 18:22:42 +0200 (CEST)"
Message-ID: <d3g0mny2cv.fsf@lxplus015.cern.ch>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: mingo@elte.hu
Cc: Andrea Arcangeli <andrea@suse.de>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Marcelo Tosatti <marcelo@conectiva.com.br>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, Roger Larsson <roger.larsson@norran.net>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

>>>>> "Ingo" == Ingo Molnar <mingo@elte.hu> writes:

Ingo> On Mon, 25 Sep 2000, Andrea Arcangeli wrote:

>> > ie. 99.45% of all allocations are single-page! 0.50% is the 8kb
>> 
>> You're right. That's why it's a waste to have so many order in the
>> buddy allocator. [...]

Ingo> yep, i agree. I'm not sure what the biggest allocation is, some
Ingo> drivers might use megabytes or contiguous RAM?

9.5KB blocks is common for people running Gigabit Ethernet with Jumbo
frames at least.

Jes
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
