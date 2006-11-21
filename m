Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e5.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id kALNppRB013551
	for <linux-mm@kvack.org>; Tue, 21 Nov 2006 18:51:51 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kALNpeOT193770
	for <linux-mm@kvack.org>; Tue, 21 Nov 2006 18:51:40 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kALNpdB5017001
	for <linux-mm@kvack.org>; Tue, 21 Nov 2006 18:51:39 -0500
Subject: Re: [PATCH 1/11] Add __GFP_MOVABLE flag and update callers
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <Pine.LNX.4.64.0611212340480.11982@skynet.skynet.ie>
References: <20061121225022.11710.72178.sendpatchset@skynet.skynet.ie>
	 <20061121225042.11710.15200.sendpatchset@skynet.skynet.ie>
	 <Pine.LNX.4.64.0611211529030.32283@schroedinger.engr.sgi.com>
	 <Pine.LNX.4.64.0611212340480.11982@skynet.skynet.ie>
Content-Type: text/plain
Date: Tue, 21 Nov 2006 15:51:36 -0800
Message-Id: <1164153096.9131.74.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 2006-11-21 at 23:43 +0000, Mel Gorman wrote:
> On Tue, 21 Nov 2006, Christoph Lameter wrote:
> > Are GFP_HIGHUSER allocations always movable? It would reduce the size of
> > the patch if this would be added to GFP_HIGHUSER.
> 
> No, they aren't. Page tables allocated with HIGHPTE are currently not 
> movable for example. A number of drivers (infiniband for example) also use 
> __GFP_HIGHMEM that are not movable.

I think Christoph was saying that it might reduce the size of the patch
to include it by _default_.  You could always go to the
weird^Wspecialized users and mask the bits back off.

We probably also need to start getting a nice list of those users which
are HIGH but not MOVABLE.  This would provide that by default, I think.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
