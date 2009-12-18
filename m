Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 777926B0044
	for <linux-mm@kvack.org>; Fri, 18 Dec 2009 15:14:43 -0500 (EST)
Date: Fri, 18 Dec 2009 12:13:22 -0800 (PST)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: Swap on flash SSDs
In-Reply-To: <20091218193911.GA6153@elte.hu>
Message-ID: <alpine.LFD.2.00.0912181211320.3712@localhost.localdomain>
References: <patchbomb.1261076403@v2.random> <alpine.DEB.2.00.0912171352330.4640@router.home> <4B2A8D83.30305@redhat.com> <alpine.DEB.2.00.0912171402550.4640@router.home> <20091218051210.GA417@elte.hu> <alpine.DEB.2.00.0912181227290.26947@router.home>
 <1261161677.27372.1629.camel@nimitz> <4B2BD55A.10404@sgi.com> <1261164487.27372.1735.camel@nimitz> <20091218193911.GA6153@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, Mike Travis <travis@sgi.com>, Christoph Lameter <cl@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>



On Fri, 18 Dec 2009, Ingo Molnar wrote:
> 
> And even when a cell does go bad and all the spares are gone, the failure mode 
> is not catastrophic like with a hard disk, but that particular cell goes 
> read-only and you can still recover the info and use the remaining cells.

Maybe. The real issue is the flash firmware. You want to bet it hasn't 
been tested very well against wear-related failures in real life? 

Once the flash firmware gets confused due to some bug, the end result is 
usually a totally dead device.

So failure modes can easily be pretty damn catastrophic. Not that that is 
in any way specific to flash (the failures I've seen on rotational disks 
have been generally catastrophic too - people who malign flashes for some 
reason don't seem to admit that rotational media tends to have all the 
same problems and then some).

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
