Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 799CB8D0039
	for <linux-mm@kvack.org>; Tue, 22 Feb 2011 10:47:33 -0500 (EST)
Date: Tue, 22 Feb 2011 09:47:26 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 3/8] Preserve local node for KSM copies
In-Reply-To: <1298315270-10434-4-git-send-email-andi@firstfloor.org>
Message-ID: <alpine.DEB.2.00.1102220945210.16060@router.home>
References: <1298315270-10434-1-git-send-email-andi@firstfloor.org> <1298315270-10434-4-git-send-email-andi@firstfloor.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, aarcange@redhat.com, lwoodman@redhat.com, Andi Kleen <ak@linux.intel.com>arcange@redhat.com

On Mon, 21 Feb 2011, Andi Kleen wrote:

> Add a alloc_page_vma_node that allows passing the "local" node in.
> Use it in ksm to allocate copy pages on the same node as
> the original as possible.

Why would that be useful? The shared page could be on a node that is not
near the process that maps the page. Would it not be better to allocate on
the node that is local to the process that maps the page?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
