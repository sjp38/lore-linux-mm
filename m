Received: from m3.gw.fujitsu.co.jp ([10.0.50.73]) by fgwmail5.fujitsu.co.jp (8.12.10/Fujitsu Gateway)
	id i7O02pJB005427 for <linux-mm@kvack.org>; Tue, 24 Aug 2004 09:02:51 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s7.gw.fujitsu.co.jp by m3.gw.fujitsu.co.jp (8.12.10/Fujitsu Domain Master)
	id i7O02o0B027253 for <linux-mm@kvack.org>; Tue, 24 Aug 2004 09:02:50 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from fjmail506.fjmail.jp.fujitsu.com (fjmail506-0.fjmail.jp.fujitsu.com [10.59.80.106]) by s7.gw.fujitsu.co.jp (8.12.11)
	id i7O02oOl012103 for <linux-mm@kvack.org>; Tue, 24 Aug 2004 09:02:50 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from jp.fujitsu.com
 (fjscan502-0.fjmail.jp.fujitsu.com [10.59.80.122]) by
 fjmail506.fjmail.jp.fujitsu.com
 (Sun Internet Mail Server sims.4.0.2001.07.26.11.50.p9)
 with ESMTP id <0I2X00FL7C4PQW@fjmail506.fjmail.jp.fujitsu.com> for
 linux-mm@kvack.org; Tue, 24 Aug 2004 09:02:49 +0900 (JST)
Date: Tue, 24 Aug 2004 09:07:59 +0900
From: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [Lhms-devel] Re: [RFC]  free_area[]  bitmap elimination [0/3]
In-reply-to: <1093273243.3153.779.camel@nighthawk>
Message-id: <412A86DF.1010409@jp.fujitsu.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-transfer-encoding: 7bit
References: <4126B3F9.90706@jp.fujitsu.com>
 <1093271785.3153.754.camel@nighthawk> <1093273243.3153.779.camel@nighthawk>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: linux-mm <linux-mm@kvack.org>, lhms <lhms-devel@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

Dave Hansen wrote:
> On Mon, 2004-08-23 at 07:36, Dave Hansen wrote:
> 
>>I'll try and give these patches a run on a NUMA-Q today.  Those machines
>>are very cache-sensitive and should magnify any positive or negative
>>effects.  
> 
> 
> DISCLAIMER: SPEC(tm) and the benchmark name SDET(tm) are registered 
> trademarks of the Standard Performance Evaluation Corporation. This 
> benchmarking was performed for research purposes only, and the run
> results are non-compliant and not-comparable with any published results.
> 
> Scripts: 32     
> Iterations: 40
>                       2.6.8.1- | 2.6.8.1-
>                       vanilla  | nofreemap
>                     -----------+-----------
> Average Throughput:   18836.68 |  18839.37
> Standard Deviation:    1538.89 |   1791.29
> 
> No statistically different results.  Very cool.
> 

Thank you for trying and testing.
This results looks  good and encourages me :)

-- Kame


-- 
--the clue is these footmarks leading to the door.--
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
