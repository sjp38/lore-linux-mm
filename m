Date: Tue, 23 May 2000 12:59:44 -0400 (EDT)
From: "Benjamin C.R. LaHaise" <blah@kvack.org>
Subject: Re: Accessing shared memory in a kernel module
In-Reply-To: <v0300780ab55062f164db@[194.5.49.5]>
Message-ID: <Pine.LNX.3.96.1000523125806.1878D-100000@kanga.kvack.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Stephane Letz <letz@grame.fr>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 23 May 2000, Stephane Letz wrote:

> We need to access to  shared memory segment in the kernel but not in the
> context of a user space process call. Actually the user application send a
> shared memory cell in the kernel module and "later" (in the context of a
> kernel timer interrupt), the kernel module needs to access the memory cell
> and give it back to another user application.
> 
> Any idea?

Without knowing more of what you're trying to do, I'll give the generic
advice of allocate the memory in your driver at startup (open or configure
time) and provide an mmap method -- see the sound drivers et al.

		-ben

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
