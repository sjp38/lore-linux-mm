From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199910111907.MAA15028@google.engr.sgi.com>
Subject: Re: locking question: do_mmap(), do_munmap()
Date: Mon, 11 Oct 1999 12:07:08 -0700 (PDT)
In-Reply-To: <38022640.3447ECA6@colorfullife.com> from "Manfred Spraul" at Oct 11, 99 08:02:40 pm
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Manfred Spraul <manfreds@colorfullife.com>
Cc: viro@math.psu.edu, sct@redhat.com, andrea@suse.de, linux-kernel@vger.rutgers.edu, mingo@chiara.csoma.elte.hu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> 
> What about something like a rw-semaphore which protects the vma list:
> vma-list modifiers [ie merge_segments(), insert_vm_struct() and
> do_munmap()] grab it exclusive, swapper grabs it "shared, starve
> exclusive".
> All other vma-list readers are protected by mm->mmap_sem.
> 
> This should not dead-lock, and no changes are required in
> vm_ops->swapout().
>

I have tried to follow most of the logic and solutions proposed
on this thread. This is the best solution, imo. In fact, I had
already coded something on these lines against a 2.2.10 kernel,
which I still have around. I will try to port this against a 
2.3.19 kernel over the next couple of days and post it for
everyone to review.

Thanks.

Kanoj
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
