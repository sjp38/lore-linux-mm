Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 212656B0044
	for <linux-mm@kvack.org>; Fri, 18 Dec 2009 13:43:37 -0500 (EST)
Date: Fri, 18 Dec 2009 19:43:21 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [mm][RFC][PATCH 0/11] mm accessor updates.
Message-ID: <20091218184321.GC17509@basil.fritz.box>
References: <20091217175338.GL9804@basil.fritz.box> <20091217190804.GB6788@linux.vnet.ibm.com> <20091217195530.GM9804@basil.fritz.box> <alpine.DEB.2.00.0912171356020.4640@router.home> <1261080855.27920.807.camel@laptop> <alpine.DEB.2.00.0912171439380.4640@router.home> <20091218051754.GC417@elte.hu> <4B2BB52A.7050103@redhat.com> <20091218171240.GB1354@elte.hu> <alpine.DEB.2.00.0912181207010.26947@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.0912181207010.26947@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Ingo Molnar <mingo@elte.hu>, Avi Kivity <avi@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andi Kleen <andi@firstfloor.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>

> The existing locking APIs are all hiding lock details at various levels.
> We have various specific APIs for specialized locks already Page locking
> etc.
> 
> How can we make progress on this if we cannot look at the mmap_sem

The point was to really make progress on vma locking we need new
semantics (finer grained range locking) that cannot be provided by a
simple wrapper.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
