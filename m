From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 01/11] mm: export vmalloc_sync_all symbol to GPL modules
Date: Thu, 1 Dec 2011 16:57:00 -0500
Message-ID: <20111201215700.GA16782__31846.5297147215$1322802738$gmane$org@infradead.org>
References: <1322775683-8741-1-git-send-email-mathieu.desnoyers@efficios.com>
	<1322775683-8741-2-git-send-email-mathieu.desnoyers@efficios.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <1322775683-8741-2-git-send-email-mathieu.desnoyers@efficios.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/devel>,
	<mailto:devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/devel>
List-Post: <mailto:devel@linuxdriverproject.org>
List-Help: <mailto:devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/devel>,
	<mailto:devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: devel-bounces@linuxdriverproject.org
Sender: devel-bounces@linuxdriverproject.org
To: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Cc: devel@driverdev.osuosl.org, David Howells <dhowells@redhat.com>, Greg Ungerer <gerg@snapgear.com>, Christoph Lameter <cl@linux-foundation.org>, D Jeff Dionne <jeff@uClinux.org>, linux-kernel@vger.kernel.org, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, lttng-dev@lists.lttng.org, Paul Mundt <lethal@linux-sh.org>, Tejun Heo <tj@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, David McCullough <davidm@snapgear.com>
List-Id: linux-mm.kvack.org

On Thu, Dec 01, 2011 at 04:41:13PM -0500, Mathieu Desnoyers wrote:
> LTTng needs this symbol exported. It calls it to ensure its tracing
> buffers and allocated data structures never trigger a page fault. This
> is required to handle page fault handler tracing and NMI tracing
> gracefully.

We:

 a) don't export symbols unless they have an intree-user
 b) especially don't export something as lowlevel as this one.
