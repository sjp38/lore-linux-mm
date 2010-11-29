Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 762076B0087
	for <linux-mm@kvack.org>; Mon, 29 Nov 2010 14:04:06 -0500 (EST)
Date: Mon, 29 Nov 2010 20:03:13 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 28 of 66] _GFP_NO_KSWAPD
Message-ID: <20101129190313.GA6118@random.random>
References: <patchbomb.1288798055@v2.random>
 <b1b95be209a2927d21c7.1288798083@v2.random>
 <20101118131839.GR8135@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101118131839.GR8135@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Borislav Petkov <bp@alien8.de>
List-ID: <linux-mm.kvack.org>

On Thu, Nov 18, 2010 at 01:18:39PM +0000, Mel Gorman wrote:
> This is not an exact merge with what's currently in mm. Look at the top
> of gfp.h and see "Plain integer GFP bitmasks. Do not use this
> directly.". The 0x400000u definition needs to go there and this becomes
> 
> #define __GFP_NO_KSWAPD		((__force_gfp_t)____0x400000u)
> 
> What you have just generates sparse warnings (I believe) so it's
> harmless.

Agreed.

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -34,6 +34,7 @@ struct vm_area_struct;
 #else
 #define ___GFP_NOTRACK		0
 #endif
+#define ___GFP_NO_KSWAPD	0x400000u
 
 /*
  * GFP bitmasks..
@@ -81,7 +82,7 @@ struct vm_area_struct;
 #define __GFP_RECLAIMABLE ((__force gfp_t)___GFP_RECLAIMABLE) /* Page is reclaimable */
 #define __GFP_NOTRACK	((__force gfp_t)___GFP_NOTRACK)  /* Don't track with kmemcheck */
 
-#define __GFP_NO_KSWAPD	((__force gfp_t)0x400000u)
+#define __GFP_NO_KSWAPD	((__force gfp_t)___GFP_NO_KSWAPD)
 
 /*
  * This may seem redundant, but it's a way of annotating false positives vs.


> Other than needing to define ____GFP_NO_KSWAPD

3 underscores.

> Acked-by: Mel Gorman <mel@csn.ul.ie>

Added, thanks!
Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
