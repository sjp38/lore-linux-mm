Date: Fri, 8 Jun 2007 14:26:10 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [PATCH 00 of 16] OOM related fixes
Message-ID: <20070608212610.GA11773@holomorphy.com>
References: <patchbomb.1181332978@v2.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <patchbomb.1181332978@v2.random>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Jun 08, 2007 at 10:02:58PM +0200, Andrea Arcangeli wrote:
> Hello everyone,
> this is a set of fixes done in the context of a quite evil workload reading
> from nfs large files with big read buffers in parallel from many tasks at
> the same time until the system goes oom. Mostly all of these fixes seems to be
> required to fix the customer workload on top of an older sles kernel. The
> forward port of the fixes has been already tested successfully on similar evil
> workloads.
> mainline vanilla running a somewhat simulated workload:
[...]

Interesting. This seems to demonstrate a need for file IO to handle
fatal signals, beyond just people wanting faster responses to kill -9.
Perhaps it's the case that fatal signals should always be handled, and
there should be no waiting primitives excluding them. __GFP_NOFAIL is
also "interesting."


-- wli

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
