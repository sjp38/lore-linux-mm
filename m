From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 01/11] mm: export vmalloc_sync_all symbol to GPL modules
Date: Thu, 1 Dec 2011 16:57:00 -0500
Message-ID: <20111201215700.GA16782__20573.8147059039$1322776656$gmane$org@infradead.org>
References: <1322775683-8741-1-git-send-email-mathieu.desnoyers@efficios.com>
 <1322775683-8741-2-git-send-email-mathieu.desnoyers@efficios.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1322775683-8741-2-git-send-email-mathieu.desnoyers@efficios.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Cc: Greg KH <greg@kroah.com>, devel@driverdev.osuosl.org, lttng-dev@lists.lttng.org, Linus Torvalds <torvalds@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, Christoph Lameter <cl@linux-foundation.org>, Tejun Heo <tj@kernel.org>, David Howells <dhowells@redhat.com>, David McCullough <davidm@snapgear.com>, D Jeff Dionne <jeff@uClinux.org>, Greg Ungerer <gerg@snapgear.com>, Paul Mundt <lethal@linux-sh.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-Id: linux-mm.kvack.org

On Thu, Dec 01, 2011 at 04:41:13PM -0500, Mathieu Desnoyers wrote:
> LTTng needs this symbol exported. It calls it to ensure its tracing
> buffers and allocated data structures never trigger a page fault. This
> is required to handle page fault handler tracing and NMI tracing
> gracefully.

We:

 a) don't export symbols unless they have an intree-user
 b) especially don't export something as lowlevel as this one.
