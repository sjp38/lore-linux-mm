Received: from dukat.scot.redhat.com (sct@dukat.scot.redhat.com [195.89.149.246])
	by kvack.org (8.8.7/8.8.7) with ESMTP id SAA18899
	for <linux-mm@kvack.org>; Tue, 6 Apr 1999 18:51:30 -0400
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14090.36825.930363.169515@dukat.scot.redhat.com>
Date: Tue, 6 Apr 1999 23:51:05 +0100 (BST)
Subject: Re: Somw questions [ MAYBE OFFTOPIC ]
In-Reply-To: <Pine.BSI.3.96.990405050919.3415A-100000@m-net.arbornet.org>
References: <19990402113555.F9584@uni-koblenz.de>
	<Pine.BSI.3.96.990405050919.3415A-100000@m-net.arbornet.org>
Sender: owner-linux-mm@kvack.org
To: Amol Mohite <amol@m-net.arbornet.org>
Cc: ralf@uni-koblenz.de, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, 5 Apr 1999 05:12:50 -0400 (EDT), Amol Mohite
<amol@m-net.arbornet.org> said:

>> A NULL pointer is just yet another invalid address.  There is no
>> special test for a NULL pointer.  Most probably for example (char
>> *)0x12345678 will be invalid as a pointer as well and treated the
>> same.  The CPU detects this when the TLB doesn't have a translation
>> valid for the access being attempted.

> Yes but how does it know it is a null pointer ?

It doesn't.  It just looks up the current VM page tables and looks for
the mapping for that page.  If there isn't such a mapping, it just
invokes a page fault handler in the O/S.

It is then up to the kernel to decide whether the pointer was just a
page which is swapped out, or a real invalid pointer.  If the kernel has
a mapping installed for that address, then it can install a valid page
in the process's address space and, if necessary, read the appropriate
page of disk to initialise it (for mmap or swap).  Otherwise, it just
generates a SEGV signal.

> On that note, when c does not allow u to dereference a void pointer , is
> this compiler  doing the trick ?

It is undefined in C.  Dereferencing a null pointer might return zero,
might return garbage or might generate a SEGV; the language doesn't do
anything special about it.  It is all up to the operating system.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
