Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id lAJJiJPv027806
	for <linux-mm@kvack.org>; Mon, 19 Nov 2007 14:44:19 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lAJJiATM082838
	for <linux-mm@kvack.org>; Mon, 19 Nov 2007 12:44:10 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lAJJi0so012883
	for <linux-mm@kvack.org>; Mon, 19 Nov 2007 12:44:00 -0700
Subject: Re: [RFC 5/7] LTTng instrumentation mm
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20071119190040.GA1609@Krystal>
References: <20071113193349.214098508@polymtl.ca>
	 <20071113194025.150641834@polymtl.ca> <1195160783.7078.203.camel@localhost>
	 <20071115215142.GA7825@Krystal> <1195164977.27759.10.camel@localhost>
	 <20071116144742.GA17255@Krystal> <1195495626.27759.119.camel@localhost>
	 <20071119185258.GA998@Krystal>  <20071119190040.GA1609@Krystal>
Content-Type: text/plain
Date: Mon, 19 Nov 2007 11:43:58 -0800
Message-Id: <1195501438.27759.130.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mathieu Desnoyers <compudj@krystal.dyndns.org>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mbligh@google.com
List-ID: <linux-mm.kvack.org>

On Mon, 2007-11-19 at 14:00 -0500, Mathieu Desnoyers wrote:
> > Well, using page_to_pfn turns out to be ugly in markers (and in
> > printks) then. Depending on the architecture, it will result in either
> > an unsigned long (x86_64) or an unsigned int (i386), which corresponds
> 
> Well, it's signed long and signed int, but the point is still valid. 

the result of page_to_pfn() may end up being signed in practice, but it
never needs to be.  Just cast it to an unsigned long and make it
consistent everywhere.  

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
