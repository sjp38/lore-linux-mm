Subject: Re: [RFC]  free_area[]  bitmap elimination [0/3]
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <1093271785.3153.754.camel@nighthawk>
References: <4126B3F9.90706@jp.fujitsu.com>
	 <1093271785.3153.754.camel@nighthawk>
Content-Type: text/plain
Message-Id: <1093273243.3153.779.camel@nighthawk>
Mime-Version: 1.0
Date: Mon, 23 Aug 2004 08:00:43 -0700
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm <linux-mm@kvack.org>, lhms <lhms-devel@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

On Mon, 2004-08-23 at 07:36, Dave Hansen wrote:
> I'll try and give these patches a run on a NUMA-Q today.  Those machines
> are very cache-sensitive and should magnify any positive or negative
> effects.  

DISCLAIMER: SPEC(tm) and the benchmark name SDET(tm) are registered 
trademarks of the Standard Performance Evaluation Corporation. This 
benchmarking was performed for research purposes only, and the run
results are non-compliant and not-comparable with any published results.

Scripts: 32     
Iterations: 40
                      2.6.8.1- | 2.6.8.1-
                      vanilla  | nofreemap
                    -----------+-----------
Average Throughput:   18836.68 |  18839.37
Standard Deviation:    1538.89 |   1791.29

No statistically different results.  Very cool.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
