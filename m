Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id AABAD6B00A9
	for <linux-mm@kvack.org>; Wed,  3 Nov 2010 23:11:40 -0400 (EDT)
Date: Wed, 3 Nov 2010 23:10:47 -0400 (EDT)
From: caiqian@redhat.com
Message-ID: <690735095.1385111288840247360.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
In-Reply-To: <1562100965.1384941288839981384.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
Subject: Re: [PATCH 00 of 66] Transparent Hugepage Support #32
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Borislav Petkov <bp@alien8.de>, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

There were some changes of behaviours with THP and KSM statistics demonstrated by this program, http://people.redhat.com/qcai/ksm01.c. 

There are 3 programs (A, B ,C) to allocate 128M memory each using KSM.
A has memory content = 'c'.
B has memory content = 'a'.
C has memory content = 'a'.
Then without THP,
pages_shared = 2
pages_sharing = 98285
pages_sharing = 98292
pages_unshared = 0
pages_volatile = 17
pages_to_scan = 98304
sleep_millisecs = 0
with THP,
pages_shared is 2.
pages_sharing is 18422.
pages_unshared is 0.
pages_volatile is 8.

Later,
A has memory content = 'c'
B has memory content = 'b'
C has memory content = 'a'.
Then without THP,
pages_shared = 3
pages_sharing = 98296
pages_unshared = 0
pages_volatile = 5
with THP,
pages_shared = 3
pages_sharing = 16358
pages_unshared = 0
pages_volatile = 23

Later,
A has memory content = 'd'
B has memory content = 'd'
C has memory content = 'd'
Then without THP,
pages_shared = 1
pages_sharing = 98274
pages_unshared = 0
pages_volatile = 29
with THP,
pages_shared = 1
pages_sharing = 8668
pages_unshared = 0
pages_volatile = 35

Finally,
A changes one page to 'e'
Then without THP,
pages_shared = 1
pages_sharing = 98274
pages_unshared = 1
pages_volatile = 28
with THP,
pages_shared = 1
pages_sharing = 8163
pages_unshared = 1
pages_volatile = 27

Are those differences for pages_sharing between with and without THP are expected?

CAI Qian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
