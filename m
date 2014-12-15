Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f173.google.com (mail-ie0-f173.google.com [209.85.223.173])
	by kanga.kvack.org (Postfix) with ESMTP id 73DF56B0070
	for <linux-mm@kvack.org>; Mon, 15 Dec 2014 00:53:14 -0500 (EST)
Received: by mail-ie0-f173.google.com with SMTP id y20so10077187ier.4
        for <linux-mm@kvack.org>; Sun, 14 Dec 2014 21:53:14 -0800 (PST)
Date: Sun, 14 Dec 2014 21:53:18 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [GIT PULL] aio: changes for 3.19
Message-Id: <20141214215318.b2b41f06.akpm@linux-foundation.org>
In-Reply-To: <20141214223936.GJ2672@kvack.org>
References: <20141214202224.GH2672@kvack.org>
	<CA+55aFxV2h1NrE87Zt7U8bsrXgeO=Tf-DyQO8wBYZ=M7WEjxKg@mail.gmail.com>
	<20141214215221.GI2672@kvack.org>
	<20141214141336.a0267e95.akpm@linux-foundation.org>
	<20141214223936.GJ2672@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin LaHaise <bcrl@kvack.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, linux-aio@kvack.org, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

On Sun, 14 Dec 2014 17:39:36 -0500 Benjamin LaHaise <bcrl@kvack.org> wrote:

> How about the documentation/comment updates below?

lgtm.

> ...
>
> +/* aio_ring_remap()
> + *	Called when th aio event ring is being relocated within the process'

"the"

> + *	address space.  The primary purpose is to update the saved address of
> + *	the aio event ring so that when the ioctx is detroyed, it gets removed
> + *	from the correct userspace address.  This is typically used when
> + *	reloading a process back into memory by checkpoint-restore.
> + */
>  static void aio_ring_remap(struct file *file, struct vm_area_struct *vma)
>  {
>  	struct mm_struct *mm = vma->vm_mm;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
