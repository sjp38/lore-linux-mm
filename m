Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 2491C6B01AC
	for <linux-mm@kvack.org>; Thu, 17 Jun 2010 21:09:41 -0400 (EDT)
Date: Fri, 18 Jun 2010 03:08:40 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFC][BUGFIX][PATCH 0/2] transhuge-memcg: some fixes (Re:
 Transparent Hugepage Support #25)
Message-ID: <20100618010840.GE5787@random.random>
References: <20100521000539.GA5733@random.random>
 <20100602144438.dc04ece7.nishimura@mxp.nes.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100602144438.dc04ece7.nishimura@mxp.nes.nec.co.jp>
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Chris Mason <chris.mason@oracle.com>, Borislav Petkov <bp@alien8.de>
List-ID: <linux-mm.kvack.org>

On Wed, Jun 02, 2010 at 02:44:38PM +0900, Daisuke Nishimura wrote:
> These are trial patches to fix the problem(based on THP-25).
> 
> [1/2] is a simple bug fix, and can be folded into "memcg compound(commit d16259c1
> at the http://git.kernel.org/?p=linux/kernel/git/andrea/aa.git)".
> [2/2] is a main patch.
> 
> Unfortunately, there seems to be some problems left, so I'm digging it and
> need more tests.
> Any comments are welcome.

Both are included in -26, but like you said there are problems
left... are you willing to fix those too? There's some slight
difference in the code here and there that makes the fixes not so
portable across releases (uncharge as param of move_account which
wasn't there before as an example...).

Thanks a lot for the help!
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
