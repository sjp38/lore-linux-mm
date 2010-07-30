Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 0F49C6B02A4
	for <linux-mm@kvack.org>; Fri, 30 Jul 2010 11:44:09 -0400 (EDT)
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by e9.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o6UFRBaY031251
	for <linux-mm@kvack.org>; Fri, 30 Jul 2010 11:27:11 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o6UFhwfx286116
	for <linux-mm@kvack.org>; Fri, 30 Jul 2010 11:43:58 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o6UFhvMK005076
	for <linux-mm@kvack.org>; Fri, 30 Jul 2010 12:43:58 -0300
Subject: Re: [PATCH] Tight check of pfn_valid on sparsemem - v4
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <alpine.DEB.2.00.1007300745180.9007@router.home>
References: <20100728155617.GA5401@barrios-desktop>
	 <alpine.DEB.2.00.1007281158150.21717@router.home>
	 <20100728225756.GA6108@barrios-desktop>
	 <alpine.DEB.2.00.1007291038100.16510@router.home>
	 <20100729161856.GA16420@barrios-desktop>
	 <alpine.DEB.2.00.1007291132210.17734@router.home>
	 <20100729170313.GB16420@barrios-desktop>
	 <alpine.DEB.2.00.1007291222410.17734@router.home>
	 <20100729183320.GH18923@n2100.arm.linux.org.uk>
	 <1280436919.16922.11246.camel@nimitz>
	 <20100729221426.GA28699@n2100.arm.linux.org.uk>
	 <1280450338.16922.11735.camel@nimitz>
	 <alpine.DEB.2.00.1007300745180.9007@router.home>
Content-Type: text/plain; charset="ANSI_X3.4-1968"
Date: Fri, 30 Jul 2010 08:43:54 -0700
Message-ID: <1280504634.16922.14449.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Milton Miller <miltonm@bga.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Kukjin Kim <kgene.kim@samsung.com>
List-ID: <linux-mm.kvack.org>

On Fri, 2010-07-30 at 07:48 -0500, Christoph Lameter wrote:
> On Thu, 29 Jul 2010, Dave Hansen wrote:
> 
> > SPARSEMEM_EXTREME would be a bit different.  It's a 2-level lookup.
> > You'd have 16 "section roots", each representing 256MB of address space.
> > Each time we put memory under one of those roots, we'd fill in a
> > 512-section second-level table, which is designed to always fit into one
> > page.  If you start at 256MB, you won't waste all those entries.
> 
> That is certain a solution to the !MMU case and it would work very much
> like a page table. If you have an MMU then the vmemmap sparsemem
> configuration can take advantage of of that to avoid the 2 level lookup.

Yup, couldn't agree more, Christoph.

It wouldn't hurt to have several them available on ARM since the
architecture is so diverse.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
