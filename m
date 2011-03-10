Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 84B4A8D003A
	for <linux-mm@kvack.org>; Thu, 10 Mar 2011 14:13:06 -0500 (EST)
Date: Thu, 10 Mar 2011 13:13:02 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: COW userspace memory mapping question
In-Reply-To: <056c7b49e7540a910b8a4f664415e638@anilinux.org>
Message-ID: <alpine.DEB.2.00.1103101309090.2161@router.home>
References: <056c7b49e7540a910b8a4f664415e638@anilinux.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mordae <mordae@anilinux.org>
Cc: linux-mm@kvack.org

On Tue, 8 Mar 2011, Mordae wrote:

> first let me apologize if I've picked a wrong address.

Its probably more an issue of us understanding what you want.

> Question: Is it possible to create a copy-on-write copy
>           of a MAP_PRIVATE|MAP_ANONYMOUS memory mapping
>           in the user space? Effectively a snapshot of
>           memory region.

fork() and clone() can do this.

>           I understand that clone() optionally does this
>           on much larger scale, but that's not really it.

Ok let say you have a memory range in the address space from which you
want to take a snapshot. How is that snapshot data visible? To another
process? Via a file?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
