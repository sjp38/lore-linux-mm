Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 874716B00EC
	for <linux-mm@kvack.org>; Wed, 17 Nov 2010 04:05:08 -0500 (EST)
Date: Wed, 17 Nov 2010 04:04:57 -0500
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: Propagating GFP_NOFS inside __vmalloc()
Message-ID: <20101117090457.GA30543@infradead.org>
References: <1289421759.11149.59.camel@oralap>
 <20101111120643.22dcda5b.akpm@linux-foundation.org>
 <1289512924.428.112.camel@oralap>
 <20101111142511.c98c3808.akpm@linux-foundation.org>
 <1289840500.13446.65.camel@oralap>
 <alpine.DEB.2.00.1011151303130.8167@chino.kir.corp.google.com>
 <20101116141130.b20a8a8d.akpm@linux-foundation.org>
 <ED9181FA-6B0E-4A7B-AA2D-7B976A876557@oracle.com>
 <alpine.DEB.2.00.1011162329570.13242@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1011162329570.13242@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andreas Dilger <andreas.dilger@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, "Ricardo M. Correia" <ricardo.correia@oracle.com>, linux-mm@kvack.org, Brian Behlendorf <behlendorf1@llnl.gov>
List-ID: <linux-mm.kvack.org>

On Tue, Nov 16, 2010 at 11:37:39PM -0800, David Rientjes wrote:
> If you _really_ need 1MB of physically contiguous memory, then you'll need 
> to find a way to do it in a reclaimable context.  If we actually can 
> remove the dependency that gfs2, ntfs, and ceph have in the kernel.org 
> kernel, then this support may be pulled out from under you; the worst-case 
> scenario for Lustre is that you'll have to modify the callchains like I 
> suggested in my original email to pass the gfp mask all the way down to 
> the pte allocators if you can't find a way to do it under GFP_KERNEL.

As Dave mentioned XFS also needs GFP_NOFS allocations in the low-level
vmap machinery, which is shared with vmalloc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
