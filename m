From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 01/11] mm: export vmalloc_sync_all symbol to GPL modules
Date: Thu, 1 Dec 2011 16:57:00 -0500
Message-ID: <20111201215700.GA16782__7055.98231074891$1322776654$gmane$org@infradead.org>
References: <1322775683-8741-1-git-send-email-mathieu.desnoyers@efficios.com>
 <1322775683-8741-2-git-send-email-mathieu.desnoyers@efficios.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by lo.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1RWEd6-0001k1-TM
	for glkm-linux-mm-2@m.gmane.org; Thu, 01 Dec 2011 22:57:21 +0100
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 01B7B6B0047
	for <linux-mm@kvack.org>; Thu,  1 Dec 2011 16:57:18 -0500 (EST)
Content-Disposition: inline
In-Reply-To: <1322775683-8741-2-git-send-email-mathieu.desnoyers@efficios.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Cc: Greg KH <greg@kroah.com>, devel@driverdev.osuosl.org, lttng-dev@lists.lttng.org, Linus Torvalds <torvalds@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, Christoph Lameter <cl@linux-foundation.org>, Tejun Heo <tj@kernel.org>, David Howells <dhowells@redhat.com>, David McCullough <davidm@snapgear.com>, D Jeff Dionne <jeff@uClinux.org>, Greg Ungerer <gerg@snapgear.com>, Paul Mundt <lethal@linux-sh.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Dec 01, 2011 at 04:41:13PM -0500, Mathieu Desnoyers wrote:
> LTTng needs this symbol exported. It calls it to ensure its tracing
> buffers and allocated data structures never trigger a page fault. This
> is required to handle page fault handler tracing and NMI tracing
> gracefully.

We:

 a) don't export symbols unless they have an intree-user
 b) especially don't export something as lowlevel as this one.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
