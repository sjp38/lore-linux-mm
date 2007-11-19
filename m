Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id lAJLQ6jb011545
	for <linux-mm@kvack.org>; Mon, 19 Nov 2007 16:26:06 -0500
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lAJLQ5do086046
	for <linux-mm@kvack.org>; Mon, 19 Nov 2007 14:26:05 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lAJLQ5v3010917
	for <linux-mm@kvack.org>; Mon, 19 Nov 2007 14:26:05 -0700
Subject: Re: [PATCH] Cast page_to_pfn to unsigned long in CONFIG_SPARSEMEM
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <1195507183.27759.150.camel@localhost>
References: <20071113194025.150641834@polymtl.ca>
	 <1195160783.7078.203.camel@localhost> <20071115215142.GA7825@Krystal>
	 <1195164977.27759.10.camel@localhost> <20071116144742.GA17255@Krystal>
	 <1195495626.27759.119.camel@localhost> <20071119185258.GA998@Krystal>
	 <1195501381.27759.127.camel@localhost> <20071119195257.GA3440@Krystal>
	 <1195502983.27759.134.camel@localhost> <20071119202023.GA5086@Krystal>
	 <20071119130801.bd7b7021.akpm@linux-foundation.org>
	 <1195507183.27759.150.camel@localhost>
Content-Type: text/plain
Date: Mon, 19 Nov 2007 13:26:02 -0800
Message-Id: <1195507562.27759.154.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mbligh@google.com
List-ID: <linux-mm.kvack.org>

On Mon, 2007-11-19 at 13:19 -0800, Dave Hansen wrote:
> On Mon, 2007-11-19 at 13:08 -0800, Andrew Morton wrote:
> > Heaven knows why though - why does __pfn_to_page() even exist?
> Perhaps it can go away with the
> discontig->sparsemem-vmemmap conversion.

In fact, Christoph Lameter's

                           Subject: 
x86_64: Make sparsemem/vmemmap the
default memory model V2
                              Date: 
        Thu, 15 Nov 2007 19:55:11
-0800 (PST)

does remove it.  

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
