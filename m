Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 09A096B0270
	for <linux-mm@kvack.org>; Fri,  9 Sep 2011 09:36:18 -0400 (EDT)
Date: Fri, 9 Sep 2011 09:36:12 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 03/10] mm: Add support for a filesystem to control swap
 files
Message-ID: <20110909133611.GB8155@infradead.org>
References: <1315566054-17209-1-git-send-email-mgorman@suse.de>
 <1315566054-17209-4-git-send-email-mgorman@suse.de>
 <20110909130007.GA11810@infradead.org>
 <20110909131550.GV14369@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110909131550.GV14369@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Christoph Hellwig <hch@infradead.org>, Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, Linux-NFS <linux-nfs@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Miller <davem@davemloft.net>, Trond Myklebust <Trond.Myklebust@netapp.com>, Neil Brown <neilb@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>

On Fri, Sep 09, 2011 at 02:15:50PM +0100, Mel Gorman wrote:
> 
> I confess I haven't investigated this direction at
> all yet.  Is it correct that your previous objection was
> http://linux.derkeiler.com/Mailing-Lists/Kernel/2009-10/msg00455.html
> and the direct-IO patchset you were thinking of was
> http://copilotco.com/mail-archives/linux-kernel.2009/msg87176.html ?

Yes.

> If so, are you suggesting that instead of swap_readpage and
> swap_writepage I look into what is required for swap to use ->readpage
> method and ->direct_IO aops?

The equivalent of ->direct_IO should be used for both reads and writes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
