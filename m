Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l5CHj6O4019840
	for <linux-mm@kvack.org>; Tue, 12 Jun 2007 13:45:06 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5CHj5DW215834
	for <linux-mm@kvack.org>; Tue, 12 Jun 2007 11:45:05 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5CHj5iO032623
	for <linux-mm@kvack.org>; Tue, 12 Jun 2007 11:45:05 -0600
Date: Tue, 12 Jun 2007 10:45:03 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [PATCH v6][RFC] Fix hugetlb pool allocation with empty nodes
Message-ID: <20070612174503.GB3798@us.ibm.com>
References: <20070611221036.GA14458@us.ibm.com> <Pine.LNX.4.64.0706111537250.20954@schroedinger.engr.sgi.com> <20070611225213.GB14458@us.ibm.com> <20070611230829.GC14458@us.ibm.com> <20070611231008.GD14458@us.ibm.com> <Pine.LNX.4.64.0706111615450.23857@schroedinger.engr.sgi.com> <20070612001542.GJ14458@us.ibm.com> <20070612034407.GB11773@holomorphy.com> <20070612050910.GU3798@us.ibm.com> <20070612051512.GC11773@holomorphy.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070612051512.GC11773@holomorphy.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Christoph Lameter <clameter@sgi.com>, lee.schermerhorn@hp.com, anton@samba.org, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 11.06.2007 [22:15:12 -0700], William Lee Irwin III wrote:
> On Mon, Jun 11, 2007 at 10:09:10PM -0700, Nishanth Aravamudan wrote:
> > Well, (presuming I understood everything you wrote :), don't we need the
> > static 'affair' to guarantee the initial allocations are approximately
> > round-robin? Or, if we aren't going to make that guarantee, than we
> > should only change that once my sysfs allocator (or its equivalent) is
> > available?
> > Just trying to get a handle on what you're suggesting without any
> > historical context.
> 
> For initially filling the pool one can just loop over nid's modulo the
> number of populated nodes and pass down a stack-allocated variable.

But how does one differentiate between "initally filling" the pool and a
later attempt to add to the pool (or even just marginally later).

I guess I don't see why folks are so against this static variable :) It
does the job and removing it seems like it could be an independent
cleanup?

Thanks,
Nish

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
