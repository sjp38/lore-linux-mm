Date: Fri, 19 Feb 1999 14:43:51 -0500 (EST)
From: "Benjamin C.R. LaHaise" <blah@kvack.org>
Subject: Re: vmalloc.c question
In-Reply-To: <36CD3BCE.9D2AE90E@earthling.net>
Message-ID: <Pine.LNX.3.95.990219144204.970A-100000@as200.spellcast.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Neil Booth <NeilB@earthling.net>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 19 Feb 1999, Neil Booth wrote:

> I have a simple question about vmalloc.c. I'm probably missing something
> obvious, but it appears to me that the list "vmlist" of the kernel's
> virtual memory areas is not protected by any kind of locking mechanism,
> and thus subject to races. (e.g. two CPUs trying to insert a new virtual
> memory block in the same place at the same time in get_vm_area).

That's probably because it assumes the caller holds the global kernel
lock (which is okay -- vmalloc can't be called from bottom half or irq
context safely anyways).

		-ben

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
