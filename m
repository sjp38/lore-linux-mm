Date: Sun, 29 Aug 1999 21:14:11 -0400 (EDT)
From: James Simmons <jsimmons@edgeglobal.com>
Subject: Re: accel handling
In-Reply-To: <14281.23624.70350.745345@dukat.scot.redhat.com>
Message-ID: <Pine.LNX.4.10.9908292111230.31607-100000@imperial.edgeglobal.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> You really need to have a cooperative locking engine.  Doing this sort
> of thing by playing VM tricks is not acceptable: you are just making the
> driver side of things simpler by placing a whole extra lot of work onto
> the VM, and things will not necessarily go any faster.  
> 
> The real problem with a VM solution is that threaded applications on a
> multi-processor machine will go *immensely* slower.  Every time you need
> to lock out a VM region, you have to send a storm of interrupts to the
> other CPUs to make sure they aren't in the middle of accessing the same
> region from a related thread.  In general, any solution which requires
> fast twiddling of VM to make this work just will not be accepted.

I though so but I wanted to see if their was a acceptable trick to handle
this.

> A combination of shared-memory spinlocks (for fast tight-loop locking)
> and SysV semaphores (for a blocking lock if the lock is taken for too
> long) can be combined to give a simple but very efficient locking engine
> for this type of thing.

Any docs on this stuff. How would I go about do this ? I really want to do
this write. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
