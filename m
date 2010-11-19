Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id CC60B6B0071
	for <linux-mm@kvack.org>; Fri, 19 Nov 2010 12:39:34 -0500 (EST)
Date: Fri, 19 Nov 2010 18:38:17 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 02 of 66] mm, migration: Fix race between
 shift_arg_pages and rmap_walk by guaranteeing rmap_walk finds PTEs created
 within the temporary stack
Message-ID: <20101119173817.GE24450@random.random>
References: <patchbomb.1288798055@v2.random>
 <ad7a334318ea379be733.1288798057@v2.random>
 <20101118111349.GG8135@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101118111349.GG8135@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Borislav Petkov <bp@alien8.de>
List-ID: <linux-mm.kvack.org>

On Thu, Nov 18, 2010 at 11:13:49AM +0000, Mel Gorman wrote:
> This old chestnut. IIRC, this was the more complete solution to a fix that made
> it into mainline. The patch still looks reasonable. It does add a kmalloc()
> but I can't remember if we decided we were ok with it or not. Can you remind

We decided the kmalloc was ok, but Linus didn't like this approach. I
kept it in my tree because I didn't want to remember when/if to add the
special check in the accurate rmap walks. I find it simpler if all
rmap walks are accurate by default.

> me? More importantly, it appears to be surviving the original testcase that
> this bug was about (20 minutes so far but will leave it a few hours). Assuming
> the test does not crash;

Sure the patch is safe.

If Linus still doesn't like this, I will immediately remove this patch
and add the special checks to the rmap walks in huge_memory.c, you
know my preference but this is a detail and my preference is
irrelevant.

Thanks,
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
