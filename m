Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 83DC98D0001
	for <linux-mm@kvack.org>; Fri, 12 Nov 2010 13:47:03 -0500 (EST)
Received: from hpaq2.eem.corp.google.com (hpaq2.eem.corp.google.com [172.25.149.2])
	by smtp-out.google.com with ESMTP id oACIl074019877
	for <linux-mm@kvack.org>; Fri, 12 Nov 2010 10:47:00 -0800
Received: from pzk33 (pzk33.prod.google.com [10.243.19.161])
	by hpaq2.eem.corp.google.com with ESMTP id oACIkc3c008521
	for <linux-mm@kvack.org>; Fri, 12 Nov 2010 10:46:59 -0800
Received: by pzk33 with SMTP id 33so539658pzk.38
        for <linux-mm@kvack.org>; Fri, 12 Nov 2010 10:46:54 -0800 (PST)
Date: Fri, 12 Nov 2010 10:46:51 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH/RFC] MM slub: add a sysfs entry to show the calculated
 number of fallback slabs
In-Reply-To: <1289561309.1972.30.camel@castor.rsk>
Message-ID: <alpine.DEB.2.00.1011121043250.5830@chino.kir.corp.google.com>
References: <1289561309.1972.30.camel@castor.rsk>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Richard Kennedy <richard@rsk.demon.co.uk>
Cc: Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux-foundation.org>, lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 12 Nov 2010, Richard Kennedy wrote:

> Add a slub sysfs entry to show the calculated number of fallback slabs.
> 
> Using the information already available it is straightforward to
> calculate the number of fallback & full size slabs. We can then track
> which slabs are particularly effected by memory fragmentation and how
> long they take to recover. 
> 
> There is no change to the mainline code, the calculation is only
> performed on request, and the value is available without having to
> enable CONFIG_SLUB_STATS.  
> 

I don't see why this information is generally useful unless debugging an 
issue where statistics are already needed such as ALLOC_SLOWPATH and 
ALLOC_SLAB, so it CONFIG_SLUB_STATS can be enabled to also track 
ORDER_FALLBACK.  All stats can be cleared by writing a '0' to its sysfs 
stats file so you can collect statistics for various workloads without 
rebooting (after doing a forced shrink, for example).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
