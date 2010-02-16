Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 343ED6B0078
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 01:20:41 -0500 (EST)
Date: Tue, 16 Feb 2010 17:20:35 +1100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch -mm 4/9 v2] oom: remove compulsory panic_on_oom mode
Message-ID: <20100216062035.GA5723@laptop>
References: <alpine.DEB.2.00.1002151416470.26927@chino.kir.corp.google.com>
 <alpine.DEB.2.00.1002151418190.26927@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1002151418190.26927@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Lubos Lunak <l.lunak@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 15, 2010 at 02:20:09PM -0800, David Rientjes wrote:
> If /proc/sys/vm/panic_on_oom is set to 2, the kernel will panic
> regardless of whether the memory allocation is constrained by either a
> mempolicy or cpuset.
> 
> Since mempolicy-constrained out of memory conditions now iterate through
> the tasklist and select a task to kill, it is possible to panic the
> machine if all tasks sharing the same mempolicy nodes (including those
> with default policy, they may allocate anywhere) or cpuset mems have
> /proc/pid/oom_adj values of OOM_DISABLE.  This is functionally equivalent
> to the compulsory panic_on_oom setting of 2, so the mode is removed.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>

What is the point of removing it, though? If it doesn't significantly
help some future patch, just leave it in. It's not worth breaking the
user/kernel interface just to remove 3 trivial lines of code.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
