Message-ID: <45E8BA31.3050808@google.com>
Date: Fri, 02 Mar 2007 15:58:41 -0800
From: "Martin J. Bligh" <mbligh@google.com>
MIME-Version: 1.0
Subject: Re: The performance and behaviour of the anti-fragmentation related
 patches
References: <20070301101249.GA29351@skynet.ie> <20070301160915.6da876c5.akpm@linux-foundation.org> <Pine.LNX.4.64.0703011642190.12485@woody.linux-foundation.org> <45E7835A.8000908@in.ibm.com> <Pine.LNX.4.64.0703011939120.12485@woody.linux-foundation.org> <20070301195943.8ceb221a.akpm@linux-foundation.org> <Pine.LNX.4.64.0703012105080.3953@woody.linux-foundation.org> <20070302162023.GA4691@linux.intel.com> <Pine.LNX.4.64.0703020903190.3953@woody.linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0703020903190.3953@woody.linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Mark Gross <mgross@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@in.ibm.com>, Mel Gorman <mel@skynet.ie>, npiggin@suse.de, clameter@engr.sgi.com, mingo@elte.hu, jschopp@austin.ibm.com, arjan@infradead.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> .. and think about a realistic future.
> 
> EVERYBODY will do on-die memory controllers. Yes, Intel doesn't do it 
> today, but in the one- to two-year timeframe even Intel will.
> 
> What does that mean? It means that in bigger systems, you will no longer 
> even *have* 8 or 16 banks where turning off a few banks makes sense. 
> You'll quite often have just a few DIMM's per die, because that's what you 
> want for latency. Then you'll have CSI or HT or another interconnect.
> 
> And with a few DIMM's per die, you're back where even just 2-way 
> interleaving basically means that in order to turn off your DIMM, you 
> probably need to remove HALF the memory for that CPU.
> 
> In other words: TURNING OFF DIMM's IS A BEDTIME STORY FOR DIMWITTED 
> CHILDREN.

Even with only 4 banks per CPU, and 2-way interleaving, we could still
power off half the DIMMs in the system. That's a huge impact on the
power budget for a large cluster.

No, it's not ideal, but what was that quote again ... "perfect is the
enemy of good"? Something like that ;-)

> There are maybe a couple machines IN EXISTENCE TODAY that can do it. But 
> nobody actually does it in practice, and nobody even knows if it's going 
> to be viable (yes, DRAM takes energy, but trying to keep memory free will 
> likely waste power *too*, and I doubt anybody has any real idea of how 
> much any of this would actually help in practice).

Batch jobs across clusters have spikes at different times of the day,
etc that are fairly predictable in many cases.

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
