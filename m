Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 7FD716B0092
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 15:33:42 -0500 (EST)
Date: Tue, 18 Jan 2011 21:32:37 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 13 of 66] export maybe_mkwrite
Message-ID: <20110118203237.GF9506@random.random>
References: <patchbomb.1288798055@v2.random>
 <15324c9c30081da3a740.1288798068@v2.random>
 <4D344EAF.1080401@petalogix.com>
 <20110117143345.GQ9506@random.random>
 <4D35A3D6.4070801@monstr.eu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4D35A3D6.4070801@monstr.eu>
Sender: owner-linux-mm@kvack.org
To: Michal Simek <monstr@monstr.eu>
Cc: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Borislav Petkov <bp@alien8.de>
List-ID: <linux-mm.kvack.org>

On Tue, Jan 18, 2011 at 03:29:42PM +0100, Michal Simek wrote:
> Of course: Look for example at this page:
> http://www.monstr.eu/wiki/doku.php?id=log:2011-01-18_11_51_49#linux_next

Ok now I see, the problem is the lack of pte_mkwrite with MMU=n.

So either we apply your patch or we move the maybe_mkwrite at the top
of huge_mm.h (before #ifdef CONFIG_TRANSPARENT_HUGEPAGE), it's up to
you...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
