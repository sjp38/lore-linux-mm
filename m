Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l5CHiZvQ013287
	for <linux-mm@kvack.org>; Tue, 12 Jun 2007 13:44:35 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5CHhSH7546566
	for <linux-mm@kvack.org>; Tue, 12 Jun 2007 13:43:28 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5CHhSUM009388
	for <linux-mm@kvack.org>; Tue, 12 Jun 2007 13:43:28 -0400
Date: Tue, 12 Jun 2007 10:43:26 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [PATCH v6][RFC] Fix hugetlb pool allocation with empty nodes
Message-ID: <20070612174326.GA3798@us.ibm.com>
References: <Pine.LNX.4.64.0706111745491.24389@schroedinger.engr.sgi.com> <20070612021245.GH3798@us.ibm.com> <Pine.LNX.4.64.0706111921370.25134@schroedinger.engr.sgi.com> <Pine.LNX.4.64.0706111923580.25207@schroedinger.engr.sgi.com> <20070612023421.GL3798@us.ibm.com> <Pine.LNX.4.64.0706111954360.25390@schroedinger.engr.sgi.com> <20070612031718.GP3798@us.ibm.com> <Pine.LNX.4.64.0706112018260.25631@schroedinger.engr.sgi.com> <20070612033050.GR3798@us.ibm.com> <Pine.LNX.4.64.0706112046380.25900@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0706112046380.25900@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 11.06.2007 [20:48:08 -0700], Christoph Lameter wrote:
> On Mon, 11 Jun 2007, Nishanth Aravamudan wrote:
> 
> > > Export a function for the interleave functionality so that we do not
> > > have to replicate the same thing in various locations in the kernel.
> > 
> > But I don't understand this at all.
> > 
> > This is *not* generically available, unless every caller has its own
> > private static variable. I don't know how to do that in C.
> 
> It is already there. Each task has a il_next field in its task struct
> for that purpose.

Ok, I see that. And it represent the next node to use for an interleaved
allocation. Makes sense to me, and I see how it's used in mempolicy.c to
achieve that. But we're running at system boot time, or whenever some
invokes the sysctl /proc/sys/vm/nr_hugepages. Do we really want to muck
with some arbitray bash shell's il_next field to achieve interleaving?
What if it's a C process that is trying to achieve actual interleaving
for other purposes and also allocates some hugepages on the system? It
seems like il_next is very much a process-related field.

When I wrote "caller", I meant calling function, sorry, not calling
process.

I'm not entirely sure how il_next is useful here, sorry.

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
