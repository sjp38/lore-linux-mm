Subject: Re: [patch] balanced highmem subsystem under pre7-9
References: <Pine.LNX.4.10.10005121155160.1988-100000@elte.hu>
From: Christoph Rohland <cr@sap.com>
Date: 12 May 2000 13:49:52 +0200
In-Reply-To: Ingo Molnar's message of "Fri, 12 May 2000 11:56:19 +0200 (CEST)"
Message-ID: <qww4s8456ov.fsf@sap.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: mingo@elte.hu
Cc: Linus Torvalds <torvalds@transmeta.com>, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

Ingo Molnar <mingo@elte.hu> writes:

> > VM: killing process ipctst
> 
> hm, IMHO it really does nothing that should make memory balance worse.
> Does the stock kernel work even after a long test?

No, I just ran a longer test. It does begin to swap out but later I
also get the following messages. (But your version does not swap out
at all without killing processes):

7  9  1 558816   3844    100  13096 266 9400   102  2361 10000  1611   0  99 1
VM: killing process ipctst
3 11  1 589464   5724    120  13044 321 6340    88  1587 4414  1404   0  99  1

Woops: just this moment I also got:
exec.c:265: bad pte f1d4dff8(0000000000104025).

Greetings
		Christoph
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
