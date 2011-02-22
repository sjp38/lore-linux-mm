Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 329EB8D0039
	for <linux-mm@kvack.org>; Tue, 22 Feb 2011 13:24:18 -0500 (EST)
Date: Tue, 22 Feb 2011 19:24:14 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH 3/8] Preserve local node for KSM copies
Message-ID: <20110222182414.GA5818@one.firstfloor.org>
References: <1298315270-10434-1-git-send-email-andi@firstfloor.org> <1298315270-10434-4-git-send-email-andi@firstfloor.org> <alpine.DEB.2.00.1102220945210.16060@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1102220945210.16060@router.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andi Kleen <andi@firstfloor.org>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, aarcange@redhat.com, lwoodman@redhat.com, Andi Kleen <ak@linux.intel.com>arcange@redhat.com

On Tue, Feb 22, 2011 at 09:47:26AM -0600, Christoph Lameter wrote:
> On Mon, 21 Feb 2011, Andi Kleen wrote:
> 
> > Add a alloc_page_vma_node that allows passing the "local" node in.
> > Use it in ksm to allocate copy pages on the same node as
> > the original as possible.
> 
> Why would that be useful? The shared page could be on a node that is not
> near the process that maps the page. Would it not be better to allocate on
> the node that is local to the process that maps the page?

Either could be wrong, but not moving the mappings seems most deterministic
to me. At least one of the processes (whoever allocated the page first) 
will stay with its local memory.

Also the alloc_page_vma_node() call is used for THP too. I guess i should
split it out.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
