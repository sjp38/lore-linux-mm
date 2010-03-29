Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id E7ED96B01FF
	for <linux-mm@kvack.org>; Mon, 29 Mar 2010 14:40:55 -0400 (EDT)
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 00 of 41] Transparent Hugepage Support #16
Message-Id: <patchbomb.1269887833@v2.random>
Date: Mon, 29 Mar 2010 20:37:13 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

Hello Andrew,

This is again against 2.6.34-rc1-mm1+ as before (I didn't find any newer -mm).

This removes PG_buddy and allows the PAE 32bit build with CONFIG_X86_PAT=y &&
CONFIG_X86_PAE=y && CONFIG_SPARSEMEM =y and fixes two bits in memcg_compound.

Removing an unconditional unnecessary PG_ bitflag is overall a gain anyway
(the added one is conditional to CONFIG_TRANSPARENT_HUGEPAGE which could be
turned off on 32bit archs depending on which feature is more or less important
to the user configuring the kernel).

        http://www.kernel.org/pub/linux/kernel/people/andrea/patches/v2.6/2.6.34-rc2-mm1/transparent_hugepage-16/
        http://www.kernel.org/pub/linux/kernel/people/andrea/patches/v2.6/2.6.34-rc2-mm1/transparent_hugepage-16.gz

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
