Date: Fri, 16 Apr 2004 23:18:47 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: Might refill_inactive_zone () be too aggressive?
Message-ID: <20040417061847.GC743@holomorphy.com>
References: <20040417060920.GC29393@flea>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20040417060920.GC29393@flea>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marc Singer <elf@buici.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 16, 2004 at 11:09:20PM -0700, Marc Singer wrote:
>   5) Removing the reclaim_mapped=1 line improves system response
>      dramatically...just as I'd expect.
> So, is this something to worry about?  Should it be a tunable feature?
> Should this be something addressed in the platform specific VM code?

A very interesting point there. The tendency to set reclaim_mapped = 1
is controlled by /proc/sys/vm/swappiness; setting that to 0 may improve
your performance or behave closer to how the case you cited where vmscan.c
never sets reclaim_mapped = 1 improved performance.

The default value is 60, which begins unmapping mapped memory about
when 40% of memory is mapped by userspace.


-- wli

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
