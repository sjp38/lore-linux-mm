Date: Mon, 4 Oct 1999 12:02:47 -0400 (EDT)
From: "Benjamin C.R. LaHaise" <blah@kvack.org>
Subject: Re: MMIO regions
In-Reply-To: <Pine.LNX.4.10.9910041146560.8080-100000@imperial.edgeglobal.com>
Message-ID: <Pine.LNX.3.96.991004115631.500A-100000@kanga.kvack.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: James Simmons <jsimmons@edgeglobal.com>
Cc: Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 4 Oct 1999, James Simmons wrote:

> And if the process holding the locks dies then no other process can access
> this resource. Also if the program forgets to release the lock you end up
> with other process never being able to access this piece of hardware.   

Eh?  That's simply not true -- it's easy enough to handle via a couple of
different means: in the release fop or munmap which both get called on
termination of a task.  Or in userspace from the SIGCHLD to the parent, or
if you're really paranoid, you can save the pid in an owner field in the
lock and periodically check that the process is still there.

		-ben

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
