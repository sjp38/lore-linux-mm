Received: from kanga.kvack.org (blah@kanga.kvack.org [199.233.184.222])
	by kvack.org (8.8.7/8.8.7) with ESMTP id NAA28982
	for <linux-mm@kvack.org>; Mon, 9 Mar 1998 13:59:52 -0500
Date: Mon, 9 Mar 1998 13:58:48 -0500 (EST)
From: "Benjamin C.R. LaHaise" <blah@kvack.org>
Subject: reverse pte mapping update
Message-ID: <Pine.LNX.3.95.980309130055.8617C-100000@kanga.kvack.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@dcs.ed.ac.uk>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello Stephen et all,

Just a quick update to say that I've got something that's half-working,
and given a few days more work it'll be worth testing.  At least it boots
and allows me to compile the next change. 

On another note, I'm becoming concerned about the manipulations being done
to vmas belonging to other mm's now - mostly that we'll be wanting to
manipulate them much more frequently than at present.  Stephen, if you
could give me a hint about what direction you're going with your page
cache locking patch, it will help me start putting together a picture of
we'll fit everything together.

Along the same line of thought, I'm wondering if we can dispense of
mm->mmap_sem for most cases?  I remember hearing that glibc will soon have
an async-io implementation, and I believe clone with shared vm is going to
be the basis for the implementation.  This will also effect a future
threaded version of apache, which will use mmap'd files across several
threads being thrown at sockets to avoid the extra copies.  Eliminating
the lock probably isn't possible, but changing it to a read-write blocking
lock is probably the easiest.  The kernel should have such a generic
primative anyways.

Linux-mm people: is anyone interested in putting together a test suite to
excercise various aspects of the mm code?  Ideally I'd like to see us put
together a large enough test suite to run a complete coverage test on the
kernel code.  Given that this is a pretty big task, it will take a while.
Perhaps running the kernel under an emulator (say 68k/Amiga as UAE is
pretty complete, barring the MMU [easy]), or using the MkLinux port
would help in creating a more useful testing environment.

		-ben
