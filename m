Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id A52B78D0007
	for <linux-mm@kvack.org>; Mon, 29 Nov 2010 10:27:08 -0500 (EST)
Date: Mon, 29 Nov 2010 10:26:36 -0500
From: Kyle McMartin <kyle@mcmartin.ca>
Subject: Re: [PATCH 1/2] mm: page allocator: Adjust the per-cpu counter
 threshold when memory is low
Message-ID: <20101129152636.GI15818@bombadil.infradead.org>
References: <1288169256-7174-1-git-send-email-mel@csn.ul.ie>
 <1288169256-7174-2-git-send-email-mel@csn.ul.ie>
 <20101126160619.GP22651@bombadil.infradead.org>
 <20101129095618.GB13268@csn.ul.ie>
 <20101129131626.GF15818@bombadil.infradead.org>
 <20101129150824.GF13268@csn.ul.ie>
 <20101129152230.GH15818@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101129152230.GH15818@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
To: Kyle McMartin <kyle@mcmartin.ca>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Shaohua Li <shaohua.li@intel.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, Nov 29, 2010 at 10:22:30AM -0500, Kyle McMartin wrote:
> Hrm, I don't think it is, I think the ones with '?' are just artifacts
> because we don't have a proper unwinder. Oh! Thanks! I just found a bug
> in our configs... We don't have CONFIG_FRAME_POINTER set because
> CONFIG_DEBUG_KERNEL got unset in the 'production' configs... I'll fix
> that up.
> 

Oops, no, misdiagnosed that by accidentally grepping for FRAME_POINTERS
instead of FRAME_POINTER... it's set in our configs.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
