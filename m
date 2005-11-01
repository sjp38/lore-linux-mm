Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id jA1EpA1B012092
	for <linux-mm@kvack.org>; Tue, 1 Nov 2005 09:51:10 -0500
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VERS6.8) with ESMTP id jA1EqDDC536774
	for <linux-mm@kvack.org>; Tue, 1 Nov 2005 07:52:13 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id jA1Ep92R002065
	for <linux-mm@kvack.org>; Tue, 1 Nov 2005 07:51:09 -0700
Subject: Re: [Lhms-devel] [PATCH 0/7] Fragmentation Avoidance V19
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <Pine.LNX.4.58.0511011358520.14884@skynet>
References: <20051030235440.6938a0e9.akpm@osdl.org>
	 <27700000.1130769270@[10.10.2.4]> <4366A8D1.7020507@yahoo.com.au>
	 <Pine.LNX.4.58.0510312333240.29390@skynet> <4366C559.5090504@yahoo.com.au>
	 <Pine.LNX.4.58.0511010137020.29390@skynet> <4366D469.2010202@yahoo.com.au>
	 <Pine.LNX.4.58.0511011014060.14884@skynet> <20051101135651.GA8502@elte.hu>
	 <Pine.LNX.4.58.0511011358520.14884@skynet>
Content-Type: text/plain
Date: Tue, 01 Nov 2005 15:50:58 +0100
Message-Id: <1130856658.14475.79.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Ingo Molnar <mingo@elte.hu>, Nick Piggin <nickpiggin@yahoo.com.au>, "Martin J. Bligh" <mbligh@mbligh.org>, Andrew Morton <akpm@osdl.org>, kravetz@us.ibm.com, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, lhms <lhms-devel@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

On Tue, 2005-11-01 at 14:41 +0000, Mel Gorman wrote:
> o Mechanism for taking regions of memory offline. Again, I think the
>   memory hotplug crowd have something for this. If they don't, one of them
>   will chime in.

I'm not sure what you're asking for here.

Right now, you can offline based on NUMA node, or physical address.
It's all revealed in sysfs.  Sounds like "regions" to me. :)

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
