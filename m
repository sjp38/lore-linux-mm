Date: Tue, 12 Jun 2007 11:50:00 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH v6][RFC] Fix hugetlb pool allocation with empty nodes
In-Reply-To: <20070612173602.GY3798@us.ibm.com>
Message-ID: <Pine.LNX.4.64.0706121149360.30754@schroedinger.engr.sgi.com>
References: <20070611221036.GA14458@us.ibm.com>
 <Pine.LNX.4.64.0706111537250.20954@schroedinger.engr.sgi.com>
 <20070611225213.GB14458@us.ibm.com> <20070611230829.GC14458@us.ibm.com>
 <20070611231008.GD14458@us.ibm.com> <Pine.LNX.4.64.0706111615450.23857@schroedinger.engr.sgi.com>
 <20070612001542.GJ14458@us.ibm.com> <20070612034407.GB11773@holomorphy.com>
 <20070612050910.GU3798@us.ibm.com> <20070612051512.GC11773@holomorphy.com>
 <20070612173602.GY3798@us.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: William Lee Irwin III <wli@holomorphy.com>, lee.schermerhorn@hp.com, anton@samba.org, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 12 Jun 2007, Nishanth Aravamudan wrote:

> > For initially filling the pool one can just loop over nid's modulo the
> > number of populated nodes and pass down a stack-allocated variable.
> 
> Ok, I'll play with that a bit.

That would work too but then you need to write your own interleave 
function.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
