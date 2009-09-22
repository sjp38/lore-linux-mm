Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 0E2016B005A
	for <linux-mm@kvack.org>; Tue, 22 Sep 2009 14:55:48 -0400 (EDT)
Received: by fxm2 with SMTP id 2so20865fxm.4
        for <linux-mm@kvack.org>; Tue, 22 Sep 2009 11:55:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1253624054-10882-2-git-send-email-mel@csn.ul.ie>
References: <1253624054-10882-1-git-send-email-mel@csn.ul.ie>
	 <1253624054-10882-2-git-send-email-mel@csn.ul.ie>
Date: Tue, 22 Sep 2009 21:55:55 +0300
Message-ID: <84144f020909221155s27facd66rc852f5e6b28eb593@mail.gmail.com>
Subject: Re: [PATCH 1/4] slqb: Do not use DEFINE_PER_CPU for per-node data
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Nick Piggin <npiggin@suse.de>, Christoph Lameter <cl@linux-foundation.org>, heiko.carstens@de.ibm.com, sachinp@in.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

On Tue, Sep 22, 2009 at 3:54 PM, Mel Gorman <mel@csn.ul.ie> wrote:
> SLQB uses DEFINE_PER_CPU to define per-node areas. An implicit
> assumption is made that all valid node IDs will have matching valid CPU
> ids. In memoryless configurations, it is possible to have a node ID with
> no CPU having the same ID. When this happens, per-cpu areas are not
> initialised and the per-node data is effectively random.
>
> An attempt was made to force the allocation of per-cpu areas corresponding
> to active node IDs. However, for reasons unknown this led to silent
> lockups. Instead, this patch fixes the SLQB problem by forcing the per-node
> data to be statically declared.
>
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>

Applied, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
