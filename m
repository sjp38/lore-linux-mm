Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 0385F6B01B2
	for <linux-mm@kvack.org>; Thu, 27 May 2010 15:03:44 -0400 (EDT)
Received: from d06nrmr1707.portsmouth.uk.ibm.com (d06nrmr1707.portsmouth.uk.ibm.com [9.149.39.225])
	by mtagate5.uk.ibm.com (8.13.1/8.13.1) with ESMTP id o4RJ3eqH002183
	for <linux-mm@kvack.org>; Thu, 27 May 2010 19:03:40 GMT
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by d06nrmr1707.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o4RJ3d3e1216742
	for <linux-mm@kvack.org>; Thu, 27 May 2010 20:03:40 +0100
Received: from d06av01.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id o4RJ3dqt026367
	for <linux-mm@kvack.org>; Thu, 27 May 2010 20:03:39 +0100
Date: Thu, 27 May 2010 21:04:40 +0200
From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: Re: [BUG] slub crashes on dma allocations
Message-ID: <20100527190440.GA2205@osiris.boeblingen.de.ibm.com>
References: <20100526153757.GB2232@osiris.boeblingen.de.ibm.com>
 <alpine.DEB.2.00.1005270916220.5762@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1005270916220.5762@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 27, 2010 at 09:17:17AM -0500, Christoph Lameter wrote:
> 
> So S390 has NUMA and the minalign is allowing very small slabs of 8/16/32 bytes?

No NUMA, but minalign is 8.

> Try this patch
> 
> From: Christoph Lameter <cl@linux-foundation.org>
> Subject: SLUB: Allow full duplication of kmalloc array for 390
> 
> Seems that S390 is running out of kmalloc caches.
> 
> Increase the number of kmalloc caches to a safe size.
> 
> Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

Yes, that fixes the bug. Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
