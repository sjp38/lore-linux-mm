From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14328.53659.36975.874284@dukat.scot.redhat.com>
Date: Mon, 4 Oct 1999 17:11:07 +0100 (BST)
Subject: Re: MMIO regions
In-Reply-To: <Pine.LNX.4.10.9910041146560.8080-100000@imperial.edgeglobal.com>
References: <14328.51304.207897.182095@dukat.scot.redhat.com>
	<Pine.LNX.4.10.9910041146560.8080-100000@imperial.edgeglobal.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: James Simmons <jsimmons@edgeglobal.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, 4 Oct 1999 11:52:50 -0400 (EDT), James Simmons
<jsimmons@edgeglobal.com> said:

>> The kernel doesn't impose any limits against this.  If you want to make
>> this impossible, then you need to add locking to the driver itself to
>> prevent multiple processes from conflicting.

> And if the process holding the locks dies then no other process can access
> this resource. Also if the program forgets to release the lock you end up
> with other process never being able to access this piece of hardware.   

There are any number of ways to recover from this.  SysV semaphores, for
example, allow you to specify UNDO when you down a semaphore, and the
semaphore will be restored automatically on process death.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
