Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 25AEF6B008C
	for <linux-mm@kvack.org>; Tue, 14 Dec 2010 12:39:11 -0500 (EST)
Date: Tue, 14 Dec 2010 18:38:21 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 38 of 66] memcontrol: try charging huge pages from stock
Message-ID: <20101214173821.GI5638@random.random>
References: <patchbomb.1288798055@v2.random>
 <9d26d3daf23632b20a7b.1288798093@v2.random>
 <20101119101427.45d78929.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101119101427.45d78929.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Borislav Petkov <bp@alien8.de>
List-ID: <linux-mm.kvack.org>

On Fri, Nov 19, 2010 at 10:14:27AM +0900, KAMEZAWA Hiroyuki wrote:
> On Wed, 03 Nov 2010 16:28:13 +0100
> Andrea Arcangeli <aarcange@redhat.com> wrote:
> 
> > From: Johannes Weiner <hannes@cmpxchg.org>
> > 
> > The stock unit is just bytes, there is no reason to only take normal
> > pages from it.
> > 
> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> > Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> 
> nonsense. The stock size is CHARGE_SIZE=32*PAGE_SIZE at maximum.
> When we make this to be larger than HUGEPAGE size, 2M per cpu at least.
> This means memcg's resource "usage" accounting will have 128MB inaccuracy.
> 
> Nack.

Removed, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
