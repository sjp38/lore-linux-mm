Date: Fri, 18 Apr 2003 16:50:07 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: Large-footprint processes in a batch-processing-like scenario
Message-ID: <20030418235007.GF16139@holomorphy.com>
References: <200304182305.h3IN5klM026249@pacific-carrier-annex.mit.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200304182305.h3IN5klM026249@pacific-carrier-annex.mit.edu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ping Huang <pshuang@alum.mit.edu>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 18, 2003 at 07:05:46PM -0400, Ping Huang wrote:
> I'm trying to figure out if there is an efficient way to coerce the
> Linux kernel to effectively swap (not demand-page) between multiple
> processes which will not all fit together into physical memory.  I'd
> be interested in peoples' comments about how they would expect the
> Linux VM subsystem to behave for the workload described below, what
> kernels might do better vs. others, and how I might tune for system
> throughput for this kind of application load.

This is generally known as load control. Linux has not yet implemented
this. Most of the other comments are over-specific. Essentially you
need the policy to effectively RR the large app instances with some
notion of how many are simultaneously runnable.

Carr (1981) describes load control policies tailored to the traditional
algorithms like clock scanning, WS, etc. They aren't directly applicable
to Linux but should give some notion of what code doing it is trying to
achieve. It's long out of print, so you may very well have to hunt for
it at a library (ILL?). The more traditional UNIX implementations (e.g.
FBSD) all do this and are probably good for the mechanical details.

It really boils down to a scheduling problem, so various queueing
tidbits can be applied with some changes to how they're phrased.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
