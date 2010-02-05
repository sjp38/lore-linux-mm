Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id C9D926B0047
	for <linux-mm@kvack.org>; Fri,  5 Feb 2010 14:14:05 -0500 (EST)
Date: Fri, 5 Feb 2010 13:12:26 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH] [2/4] SLAB: Set up the l3 lists for the memory of freshly
 added memory
In-Reply-To: <20100203213913.D5CD4B1620@basil.firstfloor.org>
Message-ID: <alpine.DEB.2.00.1002051311530.25989@router.home>
References: <201002031039.710275915@firstfloor.org> <20100203213913.D5CD4B1620@basil.firstfloor.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: submit@firstfloor.org, linux-kernel@vger.kernel.org, haicheng.li@intel.com, penberg@cs.helsinki.fi, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 3 Feb 2010, Andi Kleen wrote:

> Requires previous refactor patch.

Not in this series?

> +	if (action == MEM_ONLINE && mn->status_change_nid >= 0)
> +		slab_node_prepare(mn->status_change_nid);
> +	return NOTIFY_OK;

Never seen a slab_node_prepare function before.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
