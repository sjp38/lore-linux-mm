Date: Fri, 15 Sep 2006 00:44:02 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: [PATCH] GFP_THISNODE for the slab allocator
Message-Id: <20060915004402.88d462ff.pj@sgi.com>
In-Reply-To: <20060915002325.bffe27d1.akpm@osdl.org>
References: <Pine.LNX.4.64.0609131649110.20799@schroedinger.engr.sgi.com>
	<20060914220011.2be9100a.akpm@osdl.org>
	<20060914234926.9b58fd77.pj@sgi.com>
	<20060915002325.bffe27d1.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: clameter@sgi.com, linux-mm@kvack.org, rientjes@google.com
List-ID: <linux-mm.kvack.org>

Andrew wrote:
> Well some bright spark went and had the idea of using cpusets and fake numa
> nodes as a means of memory paritioning, didn't he?

If that bright spark is lurking here, perhaps he could educate
me a little.  I mostly ignored the fake numa node stuff when it
went by, because I figured it was just an amusing novelty.

Perhaps its time I learned why it is valuable.  Can someone
explain it to me, and describe a bit the situations in which
it is useful.  Seems like NUMA mechanisms are being (ab)used
for micro-partitioning memory.

As Andrew speculates, this could lead to reconsidering and
fancifying up some of the mechanisms, to cover a wider range
of situations efficiently.

Thanks.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
