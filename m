Message-ID: <20041205104946.67855.qmail@web53906.mail.yahoo.com>
Date: Sun, 5 Dec 2004 02:49:46 -0800 (PST)
From: Fawad Lateef <fawad_lateef@yahoo.com>
Subject: Re: Re: Is sizeof(void *) ever != sizeof(unsigned long)?
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: rml@novell.com
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--- Robert Love wrote:

> But that is not true, actually.  Nothing in C or
> anywhere else says that
> the long type has to be the size of a GPR.
> Specifically in Linux, the
> SPARC64 user-space ABI has a 32-bit long type
> despite being a 64-bit
> architecture--in other words, SPARC64 has a 32-bit
> user-space even
> though it is a 64-bit architecture.
> 
> In the kernel, however, we have the ABI such that
> both pointers and
> longs are the same size, generally the size of the
> GPR.  But there is a
> difference between physical requirements, C
> requirements, the user-space
> ABI, and the kernel ABI.
> 
> By definition (the Linux kernel ABI) they _are_
> equal in size to each
> other.
> 


Thanks for this explanation, now I got clear view abt
that.


Fawad Lateef

__________________________________________________
Do You Yahoo!?
Tired of spam?  Yahoo! Mail has the best spam protection around 
http://mail.yahoo.com 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
