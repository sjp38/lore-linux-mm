Date: Thu, 17 May 2001 22:17:02 +0200
From: Andi Kleen <ak@muc.de>
Subject: Re: Running out of vmalloc space
Message-ID: <20010517221702.A1750@fred.local>
References: <A33AEFDC2EC0D411851900D0B73EBEF766DC67@NAPA>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <A33AEFDC2EC0D411851900D0B73EBEF766DC67@NAPA>; from hji@netscreen.com on Thu, May 17, 2001 at 08:51:49PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hua Ji <hji@netscreen.com>
Cc: David Pinedo <dp@fc.hp.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 17, 2001 at 08:51:49PM +0200, Hua Ji wrote:
> For example, if your machine has a physical memory of 256M. And then your
> vmalloc can only manage
> (1G-256M-8M) space.

Not quite true with 2.4 anymore: Linux can put physical memory that doesn't
fit between PAGE_OFFSET and the beginning of special mappings into highmem,
where it is only mapped from on demand.
Highmem has some penalties (double buffering on IO, cannot be used directly
by many kernel subsystems), but is still usable.

So moderately increasing the vmalloc area should not be a big problem. Of 
course it should still leave some directly mapped space for the kernel.

-Andi
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
