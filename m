Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 18A0D6B006A
	for <linux-mm@kvack.org>; Wed, 20 Jan 2010 13:13:24 -0500 (EST)
Date: Wed, 20 Jan 2010 12:12:55 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 5/7] Add /proc trigger for memory compaction
In-Reply-To: <20100120094813.GC5154@csn.ul.ie>
Message-ID: <alpine.DEB.2.00.1001201211020.14342@router.home>
References: <1262795169-9095-1-git-send-email-mel@csn.ul.ie> <1262795169-9095-6-git-send-email-mel@csn.ul.ie> <alpine.DEB.2.00.1001071352100.23894@chino.kir.corp.google.com> <20100120094813.GC5154@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 20 Jan 2010, Mel Gorman wrote:

> True, although the per-node structures are only available on NUMA making
> it necessary to have two interfaces. The per-node one is handy enough
> because it would be just
>
> /sys/devices/system/node/nodeX/compact_node
> 	When written to, this node is compacted by the writing process
>
> But there does not appear to be a "good" way of having a non-NUMA
> interface. /sys/devices/system/node does not exist .... Does anyone
> remember why !NUMA does not have a /sys/devices/system/node/node0? Is
> there a good reason or was there just no point?

We could create a fake node0 for the !NUMA case I guess? Dont see a major
reason why not to do it aside from scripts that may check for the presence
of the file to switch to a "NUMA" mode.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
