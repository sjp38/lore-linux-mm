Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id AE0C66B00AB
	for <linux-mm@kvack.org>; Tue, 22 Sep 2009 09:38:31 -0400 (EDT)
Received: by bwz24 with SMTP id 24so2768268bwz.38
        for <linux-mm@kvack.org>; Tue, 22 Sep 2009 06:38:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1253624054-10882-3-git-send-email-mel@csn.ul.ie>
References: <1253624054-10882-1-git-send-email-mel@csn.ul.ie>
	 <1253624054-10882-3-git-send-email-mel@csn.ul.ie>
Date: Tue, 22 Sep 2009 16:38:32 +0300
Message-ID: <84144f020909220638l79329905sf9a35286130e88d0@mail.gmail.com>
Subject: Re: [PATCH 2/4] slqb: Record what node is local to a kmem_cache_cpu
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Nick Piggin <npiggin@suse.de>, Christoph Lameter <cl@linux-foundation.org>, heiko.carstens@de.ibm.com, sachinp@in.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

Hi Mel,

On Tue, Sep 22, 2009 at 3:54 PM, Mel Gorman <mel@csn.ul.ie> wrote:
> When freeing a page, SLQB checks if the page belongs to the local node.
> If it is not, it is considered a remote free. On the allocation side, it
> always checks the local lists and if they are empty, the page allocator
> is called. On memoryless configurations, this is effectively a memory
> leak and the machine quickly kills itself in an OOM storm.
>
> This patch records what node ID is considered local to a CPU. As the
> management structure for the CPU is always allocated from the closest
> node, the node the CPU structure resides on is considered "local".
>
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>

I don't understand how the memory leak happens from the above
description (or reading the code). page_to_nid() returns some crazy
value at free time? The remote list isn't drained properly?

                        Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
