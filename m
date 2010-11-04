Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 2BD798D0001
	for <linux-mm@kvack.org>; Thu,  4 Nov 2010 12:34:43 -0400 (EDT)
Date: Thu, 4 Nov 2010 17:30:26 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 00 of 66] Transparent Hugepage Support #32
Message-ID: <20101104163026.GH11602@random.random>
References: <690735095.1385111288840247360.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
 <2080208615.1392881288860072684.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2080208615.1392881288860072684.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
Sender: owner-linux-mm@kvack.org
To: CAI Qian <caiqian@redhat.com>
Cc: Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Borislav Petkov <bp@alien8.de>, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi Qian,

On Thu, Nov 04, 2010 at 04:41:12AM -0400, CAI Qian wrote:
> Thank Andrea for pointing out to me there are ongoing works for KSM
> and THP integration. Sorry for the noise.

No problem, thanks for your feedback!

The longer answer is: PageKsm pages will already co-exist fine with
PageTransHuge pages in the same vma with regular pages. So 3 type of
pages in the same vma. But before KSM scan can see the content of the
hugepages there has to be some memory pressure... So it's not ideal
and we will make KSM able to scan inside hugepages before they're
splitted (and to split them when it finds a match and then merge them
in the stable tree).

So it's perfectly normal that KSM becomes less effective when THP is
enabled. But in the mainline version we have MADV_HUGEPAGE, so if you
need KSM in full effect, you can simply "echo madvise
>/sys/kernel/mm/transparent_hugepage/enabled", and then you can decide
if to mark a mapping either with madvise(MADV_HUGEPAGE) or
madvise(MADV_MERGEABLE).

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
