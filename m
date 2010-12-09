Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 3DE766B0089
	for <linux-mm@kvack.org>; Thu,  9 Dec 2010 13:57:46 -0500 (EST)
Date: Thu, 9 Dec 2010 19:57:04 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 52 of 66] enable direct defrag
Message-ID: <20101209185704.GI19131@random.random>
References: <patchbomb.1288798055@v2.random>
 <db936dd7c1e500045f51.1288798107@v2.random>
 <20101118161740.GC8135@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101118161740.GC8135@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Borislav Petkov <bp@alien8.de>
List-ID: <linux-mm.kvack.org>

On Thu, Nov 18, 2010 at 04:17:41PM +0000, Mel Gorman wrote:
> On Wed, Nov 03, 2010 at 04:28:27PM +0100, Andrea Arcangeli wrote:
> > From: Andrea Arcangeli <aarcange@redhat.com>
> > 
> > With memory compaction in, and lumpy-reclaim removed, it seems safe enough to
> 
> While I'm hoping that my series on using compaction will be used instead
> of outright deletion of lumpy reclaim, this patch would still make
> sense.

Ok :), s/removed/disabled/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
