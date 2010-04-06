Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id B6D416B01EE
	for <linux-mm@kvack.org>; Tue,  6 Apr 2010 10:45:35 -0400 (EDT)
Message-ID: <4BBB48D7.6080303@redhat.com>
Date: Tue, 06 Apr 2010 10:44:39 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 00 of 41] Transparent Hugepage Support #17
References: <alpine.LFD.2.00.1004051326380.21411@i5.linux-foundation.org> <t2q84144f021004051346o65f03e71r5b7bb19b433ce454@mail.gmail.com> <alpine.LFD.2.00.1004051347480.21411@i5.linux-foundation.org> <20100405232115.GM5825@random.random> <alpine.LFD.2.00.1004051636060.21411@i5.linux-foundation.org> <20100406011345.GT5825@random.random> <alpine.LFD.2.00.1004051836000.5870@i5.linux-foundation.org> <alpine.LFD.2.00.1004051917310.3487@i5.linux-foundation.org> <4BBB052D.8040307@redhat.com> <4BBB2134.9090301@redhat.com> <20100406131024.GA5288@laptop>
In-Reply-To: <20100406131024.GA5288@laptop>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Avi Kivity <avi@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On 04/06/2010 09:10 AM, Nick Piggin wrote:

> I don't really agree with how virtualization problem is characterised.
> Xen's way of doing memory virtualization maps directly to normal
> hardware page tables so there doesn't seem like a fundamental
> requirement for more memory accesses.

Xen also uses nested paging whereever possible, because shadow
page tables are even slower than nested page tables.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
