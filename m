From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14357.39284.733660.301925@dukat.scot.redhat.com>
Date: Tue, 26 Oct 1999 13:07:16 +0100 (BST)
Subject: Re: Why don't we make mmap MAP_SHARED with /dev/zero possible?
In-Reply-To: <199910260158.JAA00043@chpc.ict.ac.cn>
References: <199910260158.JAA00043@chpc.ict.ac.cn>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: fxzhang@chpc.ict.ac.cn
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Stephen Tweedie <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, 26 Oct 1999 9:57:48 +0800, fxzhang <fxzhang@chpc.ict.ac.cn>
said:

> static int mmap_zero(struct file * file, struct vm_area_struct * vma)
> {
>         if (vma->vm_flags & VM_SHARED)
>                 return -EINVAL;

> I don't understand why people don't implement it.Yes,in the source,I
> find something like "the shared case is complex",Could someone tell
> me what's the difficulty?As it is a driver,I think it should not be
> too much to concern.

It is not a driver issue --- it is core to the VM.  The VM cannot
handle shared writable anonymous pages.  We're not talking about mmap
pages in this special case: we are talking about normal anonymous data
pages. 

>    Is there any good way to share memory between process at page
> granularity?That is,I can share individual pages between them?
> Threads maybe a subtitue,but there are many things that I don't want
> to share.

SysV shared memory.  "man shmget; man shmop; man shmctl"

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
