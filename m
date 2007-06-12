Date: Tue, 12 Jun 2007 12:13:47 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [PATCH v6][RFC] Fix hugetlb pool allocation with empty nodes
Message-ID: <20070612191347.GE11781@holomorphy.com>
References: <Pine.LNX.4.64.0706111537250.20954@schroedinger.engr.sgi.com> <20070611225213.GB14458@us.ibm.com> <20070611230829.GC14458@us.ibm.com> <20070611231008.GD14458@us.ibm.com> <Pine.LNX.4.64.0706111615450.23857@schroedinger.engr.sgi.com> <20070612001542.GJ14458@us.ibm.com> <20070612034407.GB11773@holomorphy.com> <20070612050910.GU3798@us.ibm.com> <20070612051512.GC11773@holomorphy.com> <20070612174503.GB3798@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070612174503.GB3798@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: Christoph Lameter <clameter@sgi.com>, lee.schermerhorn@hp.com, anton@samba.org, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 11.06.2007 [22:15:12 -0700], William Lee Irwin III wrote:
>> For initially filling the pool one can just loop over nid's modulo the
>> number of populated nodes and pass down a stack-allocated variable.

On Tue, Jun 12, 2007 at 10:45:03AM -0700, Nishanth Aravamudan wrote:
> But how does one differentiate between "initally filling" the pool and a
> later attempt to add to the pool (or even just marginally later).
> I guess I don't see why folks are so against this static variable :) It
> does the job and removing it seems like it could be an independent
> cleanup?

Well, another approach is to just statically initialize it to something
and then always check to make sure the node for the nid has memory, and
if not, find the next nid with a node with memory from the populated map.


-- wli

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
