Date: Tue, 28 Jan 2003 08:49:34 -0800
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: [PATCH] page coloring for 2.5.59 kernel, version 1
Message-ID: <1498630000.1043772571@titus>
In-Reply-To: <p73k7gpz0vu.fsf@oldwotan.suse.de>
References: <3.0.6.32.20030127224726.00806c20@boo.net.suse.lists.linux.kernel> <884740000.1043737132@titus.suse.lists.linux.kernel> <20030128071313.GH780@holomorphy.com.suse.lists.linux.kernel> <1466000000.1043770007@titus.suse.lists.linux.kernel> <p73k7gpz0vu.fsf@oldwotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: jasonp@boo.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> The main advantage of cache coloring normally is that benchmarks 
> should get stable results. Without it a benchmark result can vary based on 
> random memory allocation patterns.
> 
> Just having stable benchmarks may be worth it.

OK, I'll try to hack the scripts to measure standard deviation between runs
as well.

> I suspect the benefit will vary a lot based on the CPU. Your caches may
> have good enough associativity. On other CPUs it may make much more difference.

IIRC, P3's are 4 way associative ... people had been saying that this would
make more of a difference on machines with larger caches, which is why I ran
it ... 2Mb is fairly big for ia32. 

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
