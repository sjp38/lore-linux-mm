Subject: Re: [PATCH] page coloring for 2.5.59 kernel, version 1
References: <3.0.6.32.20030127224726.00806c20@boo.net.suse.lists.linux.kernel> <884740000.1043737132@titus.suse.lists.linux.kernel> <20030128071313.GH780@holomorphy.com.suse.lists.linux.kernel> <1466000000.1043770007@titus.suse.lists.linux.kernel>
From: Andi Kleen <ak@suse.de>
Date: 28 Jan 2003 17:37:25 +0100
In-Reply-To: "Martin J. Bligh"'s message of "28 Jan 2003 17:09:52 +0100"
Message-ID: <p73k7gpz0vu.fsf@oldwotan.suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: jasonp@boo.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

"Martin J. Bligh" <mbligh@aracnet.com> writes:

> > I think this one really needs to be done with the userspace cache
> > thrashing microbenchmarks. 
> 
> If a benefit cannot be show on some sort of semi-realistic workload,
> it's probably not worth it, IMHO.

The main advantage of cache coloring normally is that benchmarks 
should get stable results. Without it a benchmark result can vary based on 
random memory allocation patterns.

Just having stable benchmarks may be worth it.

I suspect the benefit will vary a lot based on the CPU. Your caches may
have good enough associativity. On other CPUs it may make much more difference.

-Andi
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
