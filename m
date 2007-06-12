Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l5C575G3010386
	for <linux-mm@kvack.org>; Tue, 12 Jun 2007 01:07:05 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5C575mp556748
	for <linux-mm@kvack.org>; Tue, 12 Jun 2007 01:07:05 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5C575mg024458
	for <linux-mm@kvack.org>; Tue, 12 Jun 2007 01:07:05 -0400
Date: Mon, 11 Jun 2007 22:07:02 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [PATCH v6][RFC] Fix hugetlb pool allocation with empty nodes
Message-ID: <20070612050702.GT3798@us.ibm.com>
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

Hrm, maybe that will work -- but then it means that if one is
interleaving huge pages, it will interfere with the interleaving of
small pages. Given that right now, huge pages are a rather precious
commodity, do we want this?

> > You're asking me to complicate patches that work just fine right now.
> 
> I am trying to simplify your work.

Sorry, I wasn't trying to sound unappreciative. Your suggestions are
very valuable!

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
