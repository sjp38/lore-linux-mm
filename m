Date: Tue, 23 May 2000 12:42:58 -0400 (EDT)
From: "Benjamin C.R. LaHaise" <blah@kvack.org>
Subject: Re: Accessing shared memory in a kernel module
In-Reply-To: <v03007809b5505bfec2a5@[194.5.49.5]>
Message-ID: <Pine.LNX.3.96.1000523123841.1878C-100000@kanga.kvack.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Stephane Letz <letz@grame.fr>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 23 May 2000, Stephane Letz wrote:

> We tried to use standard shmxx functions to manage shared memory and it
> work OK in user space, but we can not access the cell content in the kernel
> context.

Which kernel context -- a kernel thread?  Access to shared memory segments
is only possible from the context of a process that has mapped the shared
memory segment into its address space.  From such a context, it is
possible to make a kiobuf mapping that locks down the memory and allows
the kernel to access it.  It might be easier to solve the problem
differently as memory mapping operations should not be over used.

		-ben

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
