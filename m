Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l22GVjjN006203
	for <linux-mm@kvack.org>; Fri, 2 Mar 2007 11:31:45 -0500
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by westrelay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l22GVjrg537426
	for <linux-mm@kvack.org>; Fri, 2 Mar 2007 09:31:45 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l22GViqr011825
	for <linux-mm@kvack.org>; Fri, 2 Mar 2007 09:31:45 -0700
Message-ID: <45E8516B.5090203@austin.ibm.com>
Date: Fri, 02 Mar 2007 10:31:39 -0600
From: Joel Schopp <jschopp@austin.ibm.com>
MIME-Version: 1.0
Subject: Re: The performance and behaviour of the anti-fragmentation related
 patches
References: <20070301101249.GA29351@skynet.ie> <20070302015235.GG10643@holomorphy.com> <Pine.LNX.4.64.0703021018070.32022@skynet.skynet.ie>
In-Reply-To: <Pine.LNX.4.64.0703021018070.32022@skynet.skynet.ie>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Bill Irwin <bill.irwin@oracle.com>, akpm@linux-foundation.org, npiggin@suse.de, clameter@engr.sgi.com, mingo@elte.hu, arjan@infradead.org, torvalds@osdl.org, mbligh@mbligh.org, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

>> Exhibiting a workload where the list patch breaks down and the zone
>> patch rescues it might help if it's felt that the combination isn't as
>> good as lists in isolation. I'm sure one can be dredged up somewhere.
> 
> I can't think of a workload that totally makes a mess out of list-based. 
> However, list-based makes no guarantees on availability. If a system 
> administrator knows they need between 10,000 and 100,000 huge pages and 
> doesn't want to waste memory pinning too many huge pages at boot-time, 
> the zone-based mechanism would be what he wanted.

 From our testing with earlier versions of list based for memory hot-unplug on 
pSeries machines we were able to hot-unplug huge amounts of memory after running the 
nastiest workloads we could find for over a week.  Without the patches we were unable 
to hot-unplug anything within minutes of running the same workloads.

If something works for 99.999% of people (list based) and there is an easy way to 
configure it for the other 0.001% of the people ("zone" based) I call that a great 
solution.  I really don't understand what the resistance is to these patches.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
