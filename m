Date: Sat, 17 Apr 2004 10:57:24 -0700
From: Marc Singer <elf@buici.com>
Subject: Re: Might refill_inactive_zone () be too aggressive?
Message-ID: <20040417175723.GA3235@flea>
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

I don't think that's the whole story.  I printed distress,
mapped_ratio, and swappiness when vmscan starts trying to reclaim
mapped pages.

reclaim_mapped: distress 50  mapped_ratio 0  swappiness 60 

  50 + 60 > 100 

So, part of the problem is swappiness.  I could set that value to 25,
for example, to stop the machine from swapping.

I'd be fine stopping here, except for you comment about what
swappiness means.  In my case, nearly none of memory is mapped.  It is
zone priority which has dropped to 1 that is precipitating the
eviction.  Is this what you expect and want?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
