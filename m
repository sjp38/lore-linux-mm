Date: Tue, 20 Aug 2002 16:52:35 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: active_mm and mm
Message-ID: <20020820165235.I2645@redhat.com>
References: <20020820101950.A2645@redhat.com> <Pine.LNX.4.33.0208201031570.18993-100000@wildwood.eecs.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.33.0208201031570.18993-100000@wildwood.eecs.umich.edu>; from haih@eecs.umich.edu on Tue, Aug 20, 2002 at 10:55:04AM -0400
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hai Huang <haih@eecs.umich.edu>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, Aug 20, 2002 at 10:55:04AM -0400, Hai Huang wrote:
> Ok, I see why we're differentiating between mm and active_mm, but is this
> actually giving us a lot of benefits considering the number of context switches
> that would actually take advantage of this feature is probably small
> (well, it depends on the workload).

It's actually enormous.  There are a lot of kernel daemons that do
background IO, for example.  Those are often waking up after an IO
completes, doing a tiny amount of work to submit new IO, then sleeping
again.  Even more significant in many workloads is the idle task.

> Also, is the tlb flush operation that
> expensive?

Yes.  Modern cpus are _way_ faster than main memory, and they rely
utterly on the cache architecture to keep them busy.  Doing a tlb
flush forces the CPU to go back to main memory up to 2 times for every
single address translation that follows until the tlb is full again.
That's an enormous cost, especially on rapidly-switching workloads.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
