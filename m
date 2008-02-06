Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e32.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m16MASaV010738
	for <linux-mm@kvack.org>; Wed, 6 Feb 2008 17:10:28 -0500
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m16NEAZM142358
	for <linux-mm@kvack.org>; Wed, 6 Feb 2008 16:14:10 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m16NEAbo009448
	for <linux-mm@kvack.org>; Wed, 6 Feb 2008 16:14:10 -0700
Date: Wed, 6 Feb 2008 15:14:09 -0800
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [RFC][PATCH] mm: fix misleading __GFP_REPEAT related comments
Message-ID: <20080206231409.GH3477@us.ibm.com>
References: <20080206230512.GE3477@us.ibm.com> <Pine.LNX.4.64.0802061508150.21988@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0802061508150.21988@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: melgor@ie.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 06.02.2008 [15:08:39 -0800], Christoph Lameter wrote:
> On Wed, 6 Feb 2008, Nishanth Aravamudan wrote:
> 
> > To clarify, the flags' semantics are:
> > 
> >     __GFP_NORETRY means try no harder than one run through __alloc_pages
> > 
> >     __GFP_REPEAT means __GFP_NOFAIL
> 
> The __GFP_REPEAT == __GFP_NOFAIL? 
> 
> If so then remove __GFP_REPEAT.

I'm purely documenting the state of things in this patch. In a follow-on
set of patches, I try to change the semantics of __GFP_REPEAT for
large-order allocations.

Also, note, this is only in "this implementation" as mentioned all over
page_alloc.c.

Thanks,
Nish

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
