Received: from however ([206.171.168.138])
	(authenticated user joelkatz@webmaster.com)
	by webmaster.com (mail1.webmaster.com [216.152.64.168])
	(MDaemon.PRO.v6.8.5.R)
	with ESMTP id 64-md50000000029.tmp
	for <linux-mm@kvack.org>; Thu, 19 Feb 2004 17:06:15 -0800
From: "David Schwartz" <davids@webmaster.com>
Subject: RE: Non-GPL export of invalidate_mmap_range
Date: Thu, 19 Feb 2004 17:27:28 -0800
Message-ID: <MDEHLPKNGKAHNMBLJOLKAEJEKIAA.davids@webmaster.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
In-Reply-To: <20040218162858.2a230401.akpm@osdl.org>
Reply-To: davids@webmaster.com
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: paulmck@us.ibm.com, arjanv@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Christoph Hellwig <hch@infradead.org> wrote:

> And the "But when you distribute..." part is what the Linus doctrine rubs
> out.  Because it is unreasonable to say that a large piece of work such as
> this is "derived" from Linux.

	I think you misunderstand how the Linux kernel uses the term "derive". By a
"derived work", the GPL is invoking the legal copyright principle of a
"derivative work". You can google this term to get a better understanding of
it. The term "derived work" does not imply that the work is wholly derived.
Rather, it means that some part of the protected expression of the original
work is present in the work.

	In the specific case of Linux kernel modules, the question is whether some
part of the protectable expression in the Linkx kernel is present in the
module. This is a major issue for compiled modules distributed in object
form because the compilation process, through header files, puts pieces of
the header files in the resultant object.

	If the distributed work is in source code form, however, the argument
becomes much different. You are not likely to find pieces of the kernel code
present in the source code that's distributed. However, one possible
argument is that the module is a "sequel" to the kernel. It takes the
framework the kernel creates and builds on it. I can't write and sell a Star
Trek novel for just this reason, it would be derived from previous such
novels because it borrows their universe.

	Another possible argument is that the module code is so intertwined with
kernel code that you can't consider the module by itself a work at all.

	In the present case, we have a shim that is distributed in source form. The
main module works with other operating systems and doesn't contain much
Linux-specific code. So the module itself is not a derived work of Linux.
The shim is probably a derived work, but the shim is open source.

	So if there's a license issue, I don't know what it is.

	DS


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
