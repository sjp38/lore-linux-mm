Date: Fri, 22 Oct 1999 11:15:08 -0400 (EDT)
From: "Benjamin C.R. LaHaise" <blah@kvack.org>
Subject: Re: page faults
In-Reply-To: <Pine.LNX.4.10.9910221054550.23698-100000@imperial.edgeglobal.com>
Message-ID: <Pine.LNX.3.96.991022111304.11326A-100000@kanga.kvack.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: James Simmons <jsimmons@edgeglobal.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 22 Oct 1999, James Simmons wrote:

> Thank you for that answer. I remember you told me that threads under linux
> is defined as two processes sharing the same memory. So when a minor
> page fault happens by anyone one process will both process page tables get
> updated? Or does the other process will have a minor page itself
> independent of the other process? 

Threads share the same page tables, hence the same memory.  The other task
might end up with a minor fault, but after it aquires the semaphore, it
will discover the pte is already freshly faulted in.

		-ben

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
