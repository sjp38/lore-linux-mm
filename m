Date: Sat, 17 Apr 2004 07:08:12 -0700
From: Marc Singer <elf@buici.com>
Subject: Re: Might refill_inactive_zone () be too aggressive?
Message-ID: <20040417140811.GA554@flea>
References: <20040417060920.GC29393@flea> <20040417061847.GC743@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20040417061847.GC743@holomorphy.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>, Marc Singer <elf@buici.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 16, 2004 at 11:18:47PM -0700, William Lee Irwin III wrote:
> On Fri, Apr 16, 2004 at 11:09:20PM -0700, Marc Singer wrote:
> >   5) Removing the reclaim_mapped=1 line improves system response
> >      dramatically...just as I'd expect.
> > So, is this something to worry about?  Should it be a tunable feature?
> > Should this be something addressed in the platform specific VM code?
> 
> A very interesting point there. The tendency to set reclaim_mapped = 1
> is controlled by /proc/sys/vm/swappiness; setting that to 0 may improve
> your performance or behave closer to how the case you cited where vmscan.c
> never sets reclaim_mapped = 1 improved performance.
> 
> The default value is 60, which begins unmapping mapped memory about
> when 40% of memory is mapped by userspace.

I did a little more looking at when reclaim_mapped is set to one.  In
my case, I don't think that very much memory is mapped.  I've got one
program running that has one or two code pages, there may be some
libraries.  The system has 28MiB of free RAM.  I don't see how I could
be getting more than 20% of RAM mapped.
 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
