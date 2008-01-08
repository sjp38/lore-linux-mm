Date: Tue, 8 Jan 2008 08:28:12 +0100
From: Andrea Arcangeli <andrea@cpushare.com>
Subject: Re: [PATCH 10 of 11] limit reclaim if enough pages have been freed
Message-ID: <20080108072812.GA22800@v2.random>
References: <30fd9dd17ca34a24f066.1199326156@v2.random> <Pine.LNX.4.64.0801071135380.23617@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0801071135380.23617@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

On Mon, Jan 07, 2008 at 11:37:19AM -0800, Christoph Lameter wrote:
> On Thu, 3 Jan 2008, Andrea Arcangeli wrote:
> 
> > No need to wipe out an huge chunk of the cache.
> 
> Wiping out a larger chunk of the cache avoids triggering reclaim too 
> frequently.

The idea is that if you want to wipe a larger chunk to batch reclaim
more aggressively you can add a new param in addition to
swap-cluster-max. But wiping such a chunk as large as it is now sounds
bad for latency reasons (think also -rt... ok any -rt guarantee is
gone the moment you enter the VM, but still this spot is easy to fix
and benefits all my kernels with PREEMPT=n too).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
