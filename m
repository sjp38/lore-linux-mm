Date: Fri, 3 Nov 2000 20:28:30 -0500 (EST)
From: Eric Lowe <elowe@myrile.madriver.k12.oh.us>
Subject: Re: PATCH [2.4.0test10]: Kiobuf#02, fault-in fix
In-Reply-To: <20001102155835.F1876@redhat.com>
Message-ID: <Pine.BSF.4.10.10011032026460.1962-100000@myrile.madriver.k12.oh.us>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Jeff Garzik <jgarzik@mandrakesoft.com>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@nl.linux.org>, Ingo Molnar <mingo@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

> Yes.  The kernel often has to make these checks the non-intuitive way
> round, because a disk or network read IO actually involves write to
> memory, but a write IO only has to read from memory.  The convention
> is that read/write flags which affect IO paths indicate whether we are
> writing from backing store, so we have to invert the sense to decide
> whether it's a write to memory.
> 
> > This seems to further imply datain means 'read access':
> > 	if (((datain) && (!(vma->vm_flags & VM_WRITE))) ||
> 
> No, because the next line is
> 				err = -EACCES;
> so (rw==READ) and !VM_WRITE is an error --- datain does imply write
> access to memory.

That's why I call it write_access in my patches instead:
there's no ambiguity about what we mean. :)  But in any 
case, it's much better than using (rw==READ) everywhere like
it used to be ...

--
Eric Lowe
Software Engineer, Systran Corporation
elowe@systran.com


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
