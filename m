From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14338.17769.942609.464811@dukat.scot.redhat.com>
Date: Mon, 11 Oct 1999 21:15:37 +0100 (BST)
Subject: Re: locking question: do_mmap(), do_munmap()
In-Reply-To: <38022640.3447ECA6@colorfullife.com>
References: <Pine.GSO.4.10.9910111157310.18777-100000@weyl.math.psu.edu>
	<38022640.3447ECA6@colorfullife.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Manfred Spraul <manfreds@colorfullife.com>
Cc: Alexander Viro <viro@math.psu.edu>, "Stephen C. Tweedie" <sct@redhat.com>, Andrea Arcangeli <andrea@suse.de>, linux-kernel@vger.rutgers.edu, Ingo Molnar <mingo@chiara.csoma.elte.hu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, 11 Oct 1999 20:02:40 +0200, Manfred Spraul
<manfreds@colorfullife.com> said:

> What about something like a rw-semaphore which protects the vma list:
> vma-list modifiers [ie merge_segments(), insert_vm_struct() and
> do_munmap()] grab it exclusive, swapper grabs it "shared, starve
> exclusive".
> All other vma-list readers are protected by mm->mmap_sem.

> This should not dead-lock, and no changes are required in
> vm_ops-> swapout().

The swapout method will need to drop the spinlock.  We need to preserve
the vma over the call into the swapout method, and the method will need
to be able to block.  

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
