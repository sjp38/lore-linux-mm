Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 463346001DA
	for <linux-mm@kvack.org>; Mon, 22 Feb 2010 12:53:55 -0500 (EST)
Message-ID: <4B82C487.9020407@redhat.com>
Date: Mon, 22 Feb 2010 12:53:11 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch 25/36] _GFP_NO_KSWAPD
References: <20100221141009.581909647@redhat.com> <20100221141756.772875923@redhat.com>
In-Reply-To: <20100221141756.772875923@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: aarcange@redhat.com
Cc: linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>
List-ID: <linux-mm.kvack.org>

On 02/21/2010 09:10 AM, aarcange@redhat.com wrote:
> From: Andrea Arcangeli<aarcange@redhat.com>
>
> Transparent hugepage allocations must be allowed not to invoke kswapd or any
> other kind of indirect reclaim (especially when the defrag sysfs is control
> disabled). It's unacceptable to swap out anonymous pages (potentially
> anonymous transparent hugepages) in order to create new transparent hugepages.
> This is true for the MADV_HUGEPAGE areas too (swapping out a kvm virtual
> machine and so having it suffer an unbearable slowdown, so another one with
> guest physical memory marked MADV_HUGEPAGE can run 30% faster if it is running
> memory intensive workloads, makes no sense). If a transparent hugepage
> allocation fails the slowdown is minor and there is total fallback, so kswapd
> should never be asked to swapout memory to allow the high order allocation to
> succeed.
>
> Signed-off-by: Andrea Arcangeli<aarcange@redhat.com>

Acked-by: Rik van Riel <riel@redhat.com>

Once Mel's defragmentation code is in, we can kick off
that code instead when a hugepage allocation fails.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
