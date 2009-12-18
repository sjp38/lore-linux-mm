Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 3175C6B0044
	for <linux-mm@kvack.org>; Fri, 18 Dec 2009 14:39:04 -0500 (EST)
Date: Fri, 18 Dec 2009 20:38:59 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: Swap on flash SSDs
Message-ID: <20091218193859.GE17509@basil.fritz.box>
References: <patchbomb.1261076403@v2.random> <alpine.DEB.2.00.0912171352330.4640@router.home> <4B2A8D83.30305@redhat.com> <alpine.DEB.2.00.0912171402550.4640@router.home> <20091218051210.GA417@elte.hu> <alpine.DEB.2.00.0912181227290.26947@router.home> <1261161677.27372.1629.camel@nimitz> <4B2BD55A.10404@sgi.com> <1261164487.27372.1735.camel@nimitz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1261164487.27372.1735.camel@nimitz>
Sender: owner-linux-mm@kvack.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Mike Travis <travis@sgi.com>, Christoph Lameter <cl@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

> Modern, well-made flash SSDs and other flash devices have wear-leveling
> built in so that they wear all of the flash cells evenly.  There's still
> a discrete number of writes that they can handle over their life, but it
> should be high enough that you don't notice.

The keyword is "well-made"

It depends on how much you pay for it. Don't expect that from
super cheap USB sticks. But I believe it to be true for higher
end flash, with a continuum there 
(server > highend consumer > lowend consumer >> cheap junk)

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
