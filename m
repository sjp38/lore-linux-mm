From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14282.24705.733807.970163@dukat.scot.redhat.com>
Date: Mon, 30 Aug 1999 11:44:17 +0100 (BST)
Subject: Re: accel handling
In-Reply-To: <Pine.LNX.4.10.9908292111230.31607-100000@imperial.edgeglobal.com>
References: <14281.23624.70350.745345@dukat.scot.redhat.com>
	<Pine.LNX.4.10.9908292111230.31607-100000@imperial.edgeglobal.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: James Simmons <jsimmons@edgeglobal.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Sun, 29 Aug 1999 21:14:11 -0400 (EDT), James Simmons
<jsimmons@edgeglobal.com> said:

>> A combination of shared-memory spinlocks (for fast tight-loop locking)
>> and SysV semaphores (for a blocking lock if the lock is taken for too
>> long) can be combined to give a simple but very efficient locking engine
>> for this type of thing.

> Any docs on this stuff. How would I go about do this ? I really want to do
> this write. 

There are spinlock primitives in linux/asm/spinlock.h, and the
underlying atomic bit operations are in linux/asm/bitops.h.  man shmop
and man semop for information about SysV shared memory and semaphores.

--Stephen

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
