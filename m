Subject: Re: Is sizeof(void *) ever != sizeof(unsigned long)?
From: Robert Love <rml@novell.com>
In-Reply-To: <1102155752.1018.7.camel@desktop.cunninghams>
References: <1102155752.1018.7.camel@desktop.cunninghams>
Content-Type: text/plain
Date: Sat, 04 Dec 2004 11:26:17 -0500
Message-Id: <1102177577.6052.39.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: ncunningham@linuxmail.org
Cc: Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sat, 2004-12-04 at 21:40 +1100, Nigel Cunningham wrote:

> I guess the subject line says it all.

In general?  Sure.  There is no guarantee in C or the "ABI Writer's
Handbook."

In Linux, though, especially the kernel, we run with that assumption.
An "unsigned long" can always hold a pointer, it is always equal to the
wordsize.  This just means that architecture ports in Linux have to be
LP32 or LP64 or whatever.

A lot of code in the kernel uses an "unsigned long" instead of a "void*"
to hold a generic memory address.  I personally like this practice, if
you never intend to directly dereference the pointer.

	Robert Love


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
