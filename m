Date: Fri, 30 Aug 2002 15:05:50 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: Avoiding the highmem mess
Message-ID: <20020830220550.GV18114@holomorphy.com>
References: <0334AD85-BC63-11D6-B00B-000393829FA4@cs.amherst.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <0334AD85-BC63-11D6-B00B-000393829FA4@cs.amherst.edu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Scott Kaplan <sfkaplan@cs.amherst.edu>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 30, 2002 at 05:54:09PM -0400, Scott Kaplan wrote:
> SO!  To that end, I'd like to avoid the ZONE_HIGHMEM mess.  It seems oddly 
> done, and creates new kinds of contention between pools of pages that I 
> don't want polluting my experiments.  (That's not to say that I don't 
> think it's a problem worth solving -- it's just not *the* problem that *I*
>  want to examine just yet.)

You'll be fine if you keep physical memory down to less than the kernel
portion of the kernel/user split on 32-bit machines. In principle, if
there were a CONFIG_ISA to #undef and all you had were properly
functioning devices (e.g. no sound cards with only 24 lines wired) and
you could ignore it. OTOH it can be ignored anyway for the most part as
it's a very small pool and not heavily used unless your hardware is bad.

It probably won't be that much of an issue as 2.5.32-bk and/or -mm2 has
separate queues per-zone.


Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
