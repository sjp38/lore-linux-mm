From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <14426.51375.939634.483532@dukat.scot.redhat.com>
Date: Fri, 17 Dec 1999 23:35:11 +0000 (GMT)
Subject: Re: Limitation of buffer allocation
In-Reply-To: <385A3DF0.7B82AE33@bbcom-hh.de>
References: <385A3DF0.7B82AE33@bbcom-hh.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Wurbs <wurbs@bbcom-hh.de>
Cc: Linux-MM@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Fri, 17 Dec 1999 14:43:12 +0100, Peter Wurbs <wurbs@bbcom-hh.de>
said:

> If there is a ad-hoc requierement of a bigger memory block, this
> function seems to be unable to take away memory from the buffer cache.
> Thus alloc_skb returns null pointer, because it must be invoked with
> flag "GFP_ATOMIC" (sudden return if there is no memory available). As a
> result the driver runs into a faulty deadlocked state.

Yes, that's all working exactly as expected.

GFP_ATOMIC allocations are always expected to fail immediately if there
is insufficient memory available.  If you want to keep a
larger-than-normal amount of free space available for atomica
llocations, then increase the free pages count in
/proc/sys/vm/freepages. 

> Do you see problems in changing the values in /proc/sys/vm/freepages?

No, that's precisely what you are supposed to do!

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
