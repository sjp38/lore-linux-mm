Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 212DB6B0044
	for <linux-mm@kvack.org>; Sat, 19 Dec 2009 13:38:57 -0500 (EST)
Date: Sat, 19 Dec 2009 19:38:33 +0100
From: =?utf-8?B?SsO2cm4=?= Engel <joern@logfs.org>
Subject: Re: Swap on flash SSDs
Message-ID: <20091219183833.GA23426@logfs.org>
References: <patchbomb.1261076403@v2.random> <alpine.DEB.2.00.0912171352330.4640@router.home> <4B2A8D83.30305@redhat.com> <alpine.DEB.2.00.0912171402550.4640@router.home> <20091218051210.GA417@elte.hu> <alpine.DEB.2.00.0912181227290.26947@router.home> <1261161677.27372.1629.camel@nimitz> <4B2BD55A.10404@sgi.com> <1261164487.27372.1735.camel@nimitz> <20091218193911.GA6153@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20091218193911.GA6153@elte.hu>
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, Mike Travis <travis@sgi.com>, Christoph Lameter <cl@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, "Stephen C. Tweedie" <sct@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, 18 December 2009 20:39:11 +0100, Ingo Molnar wrote:
> 
> And even when a cell does go bad and all the spares are gone, the failure mode 
> is not catastrophic like with a hard disk, but that particular cell goes 
> read-only and you can still recover the info and use the remaining cells.

Pretty much all modern flash suffers write disturb and even read
disturb.  So if any cell (I guess you mean block?) goes read-only,
errors will start to accumulate and ultimately defeat error correction.

Yes, you only have a couple of bit flips.  A sufficiently motivated
human can salvage a lot of data from such a device.  But read-only does
not mean error-free.

Plus Linus' comment about firmware bugs, of course. ;)

JA?rn

-- 
Mundie uses a textbook tactic of manipulation: start with some
reasonable talk, and lead the audience to an unreasonable conclusion.
-- Bruce Perens

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
