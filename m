Subject: Re: Is sizeof(void *) ever != sizeof(unsigned long)?
From: Robert Love <rml@novell.com>
In-Reply-To: <20041204170217.45200.qmail@web53908.mail.yahoo.com>
References: <20041204170217.45200.qmail@web53908.mail.yahoo.com>
Content-Type: text/plain
Date: Sat, 04 Dec 2004 16:32:41 -0500
Message-Id: <1102195961.6052.71.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Fawad Lateef <fawad_lateef@yahoo.com>
Cc: ncunningham@linuxmail.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 2004-12-04 at 09:02 -0800, Fawad Lateef wrote:
> The sizeof(<pointer>) is always of 32bits or 4bytes on
> x86 Architecture, and you can say that it is actually
> the virtual address size of the Architecture. And
> unsigned long is actually what I understand is the
> size which a single architecture can address in a
> single atempt, like roughly you can say that in x86
> architecture long can be accesses in single cycle.

I think the term that you want is "word size" -- you want to say that a
C long type is guaranteed to be the word size, which is generally the
size of a single GPR.

But that is not true, actually.  Nothing in C or anywhere else says that
the long type has to be the size of a GPR. Specifically in Linux, the
SPARC64 user-space ABI has a 32-bit long type despite being a 64-bit
architecture--in other words, SPARC64 has a 32-bit user-space even
though it is a 64-bit architecture.

In the kernel, however, we have the ABI such that both pointers and
longs are the same size, generally the size of the GPR.  But there is a
difference between physical requirements, C requirements, the user-space
ABI, and the kernel ABI.

> By defination, they can be not equal to each other but
> practically it is same .........

By definition (the Linux kernel ABI) they _are_ equal in size to each
other.

	Robert Love


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
