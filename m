Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 87C486B007B
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 09:56:21 -0500 (EST)
Date: Tue, 16 Feb 2010 08:55:46 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 05/12] Memory compaction core
In-Reply-To: <20100216084800.GC26086@csn.ul.ie>
Message-ID: <alpine.DEB.2.00.1002160849460.18275@router.home>
References: <1265976059-7459-1-git-send-email-mel@csn.ul.ie> <1265976059-7459-6-git-send-email-mel@csn.ul.ie> <20100216170014.7309.A69D9226@jp.fujitsu.com> <20100216084800.GC26086@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 16 Feb 2010, Mel Gorman wrote:

> Because how do I tell in advance that the data I am migrating from DMA can
> be safely relocated to the NORMAL zone? We don't save GFP flags. Granted,
> for DMA, that will not matter as pages that must be in DMA will also not by
> migratable. However, buffer pages should not get relocated to HIGHMEM for
> example which is more likely to happen. It could be special cased but
> I'm not aware of ZONE_DMA-related pressure problems that would make this
> worthwhile and if so, it should be handled as a separate patch series.

Oh there are numerous ZONE_DMA pressure issues if you have ancient /
screwed up hardware that can only operate on DMA or DMA32 memory.

Moving page cache pages out of the DMA zone would be good. A
write request will cause the page to bounce back to the DMA zone if the
device requires the page there.

But I also think that the patchset should be as simple as possible so that
it can be merged soon.

> Ah, it was 2009 when I last kicked this around heavily :) I'll update
> it.

But it was authored in 2009. May be important if patent or other
copyright claims arise. 2009-2010?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
