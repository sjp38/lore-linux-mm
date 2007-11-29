Date: Thu, 29 Nov 2007 10:47:26 -0500
From: Rik van Riel <riel@redhat.com>
Subject: Re: What can we do to get ready for memory controller merge in
 2.6.25
Message-ID: <20071129104726.5698321f@cuia.boston.redhat.com>
In-Reply-To: <474ED005.7060300@linux.vnet.ibm.com>
References: <474ED005.7060300@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, linux kernel mailing list <linux-kernel@vger.kernel.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Hugh Dickins <hugh@veritas.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Pavel Emelianov <xemul@sw.ru>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Christoph Lameter <clameter@sgi.com>, "Martin J. Bligh" <mbligh@google.com>, Andy Whitcroft <andyw@uk.ibm.com>, Srivatsa Vaddagiri <vatsa@in.ibm.com>
List-ID: <linux-mm.kvack.org>

On Thu, 29 Nov 2007 20:13:17 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> They say better strike when the iron is hot.
> 
> Since we have so many people discussing the memory controller, I would
> like to access the readiness of the memory controller for mainline
> merge.

> At the VM-Summit we decided to try the current double LRU approach for
> memory control. At this juncture in the space-time continuum, I seek
> your support, feedback, comments and help to move the memory controller

The memory controller code currently in -mm seems fine to me,
especially with the changes that got committed over the last
days making reclaim more efficient.

I don't think there are any bugs left that can be found by
code inspection - only the kind of testing that the mainline
kernel gets might shake out more bugs.

I would like to see the memory controller code go into the
mainline kernel ASAP.

-- 
All Rights Reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
