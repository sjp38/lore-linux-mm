Date: Sat, 25 Sep 1999 19:06:44 +0200 (CEST)
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: mm->mmap_sem
In-Reply-To: <Pine.LNX.4.10.9909251232540.22660-100000@imperial.edgeglobal.com>
Message-ID: <Pine.LNX.4.10.9909251905110.4120-100000@laser.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: James Simmons <jsimmons@edgeglobal.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 25 Sep 1999, James Simmons wrote:

>Is their any way to do cooperative locking kernel side between two memory
>regions? If one is being access you can't physically access the other. I
>just want to process to sleep not kill it if it attempts this.

Ah ok.

So just add a spinlock in userspace. As test_and_set_bit works in
userspace also the spinlock will work fine in userspace.

Just make sure to always have the lock held before touching the memory
region you want to serialize the accesses to.

You need to add the locking into userspace.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
