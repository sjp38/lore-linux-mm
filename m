Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 95AA66B0047
	for <linux-mm@kvack.org>; Thu, 25 Feb 2010 15:58:55 -0500 (EST)
Date: Thu, 25 Feb 2010 14:58:52 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: vmapping user pages - feasible?
In-Reply-To: <hm6l5q$rqp$1@dough.gmane.org>
Message-ID: <alpine.DEB.2.00.1002251455550.18861@router.home>
References: <hm6l5q$rqp$1@dough.gmane.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Zenek <zenblu@wp.pl>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 25 Feb 2010, Zenek wrote:

> my kernel driver gets a userspace pointer to a memory area (virtually
> contiguous), allocated by userspace. I would like to use that memory in a
> vmalloc-like manner, i.e. I want it to be:

Its already virtually mapped for the process. The kernel can access the
data.

> I will be writing to it using the CPU only, in kernel mode.

Thats possible already.

> I understand that:
> - no page pinning is required (as only the CPU will be writing to that
> area)

Page pinning is required if the access from the kernel is asynchrononous
to user space.

> There will be no multithreaded access to that memory.

The kernel and userspace are not concurrently accessing the memory?

> If the userspace free()s the memory, I still have the pages unless I
> vunmap() them, right?

If you increase the page count then you still have the pages. The virtual
mapping goes away with the process.

> How should I go about it? Get the user's vm_area_struct, go through all
> the pages, construct an array of struct *page and vmap it?

Do a get_user_pages() on the range?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
