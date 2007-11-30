From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: What can we do to get ready for memory controller merge in 2.6.25
Date: Fri, 30 Nov 2007 13:11:47 +1100
References: <474ED005.7060300@linux.vnet.ibm.com>
In-Reply-To: <474ED005.7060300@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200711301311.48291.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, linux kernel mailing list <linux-kernel@vger.kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Hugh Dickins <hugh@veritas.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Pavel Emelianov <xemul@sw.ru>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Rik van Riel <riel@redhat.com>, Christoph Lameter <clameter@sgi.com>, "Martin J. Bligh" <mbligh@google.com>, Andy Whitcroft <andyw@uk.ibm.com>, Srivatsa Vaddagiri <vatsa@in.ibm.com>
List-ID: <linux-mm.kvack.org>

On Friday 30 November 2007 01:43, Balbir Singh wrote:
> They say better strike when the iron is hot.
>
> Since we have so many people discussing the memory controller, I would
> like to access the readiness of the memory controller for mainline
> merge. Given that we have some time until the merge window, I'd like to
> set aside some time (from my other work items) to work on the memory
> controller, fix review comments and defects.
>
> In the past, we've received several useful comments from Rik Van Riel,
> Lee Schermerhorn, Peter Zijlstra, Hugh Dickins, Nick Piggin, Paul Menage
> and code contributions and bug fixes from Hugh Dickins, Pavel Emelianov,
> Lee Schermerhorn, YAMAMOTO-San, Andrew Morton and KAMEZAWA-San. I
> apologize if I missed out any other names or contributions
>
> At the VM-Summit we decided to try the current double LRU approach for
> memory control. At this juncture in the space-time continuum, I seek
> your support, feedback, comments and help to move the memory controller

Do you have any test cases, performance numbers, etc.? And also some
results or even anecdotes of where this is going to be used would be
interesting...

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
