Date: Fri, 12 May 2000 09:12:20 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [patch] balanced highmem subsystem under pre7-9
In-Reply-To: <qwwhfc45ef3.fsf@sap.com>
Message-ID: <Pine.LNX.4.10.10005120910130.4909-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Rohland <cr@sap.com>
Cc: mingo@elte.hu, MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>


On 12 May 2000, Christoph Rohland wrote:
> 
> Your patch breaks my tests again (Which run fine for some time now on
> pre7):

Notsurprising, actually.

Never balancing highmem pages will also mean that they never get swapped
out. Which makes sense - why should we try to page anything out if we're
not interested in having any free pages for that zone?

So at some point the VM subsystem will just give up: 90% of the pages it
sees are unswappable, and it still cannot make room to free pages..

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
