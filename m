Message-ID: <4891C66A.3040302@linux-foundation.org>
Date: Thu, 31 Jul 2008 09:04:26 -0500
From: Christoph Lameter <cl@linux-foundation.org>
MIME-Version: 1.0
Subject: Re: [RFC:Patch: 000/008](memory hotplug) rough idea of pgdat removing
References: <20080731203549.2A3F.E1E9C6FF@jp.fujitsu.com>
In-Reply-To: <20080731203549.2A3F.E1E9C6FF@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: Badari Pulavarty <pbadari@us.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm <linux-mm@kvack.org>, Linux Kernel ML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Yasunori Goto wrote:

> Current my idea is using RCU feature for waiting them.
> Because it is the least impact against reader's performance,
> and pgdat remover can wait finish of reader's access to pgdat
> which is removing by synchronize_sched().

The use of RCU disables preemption which has implications as to what can be done in a loop over nodes or zones. This would also potentially add more overhead to the page allocator hotpaths.


> If you have better idea, please let me know.

Use stop_machine()? The removal of a zone or node is a pretty rare event after all and it would avoid having to deal with rcu etc etc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
