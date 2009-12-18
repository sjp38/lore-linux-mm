Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id CDEEF6B0044
	for <linux-mm@kvack.org>; Fri, 18 Dec 2009 14:28:22 -0500 (EST)
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by e5.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id nBIJGY62022479
	for <linux-mm@kvack.org>; Fri, 18 Dec 2009 14:16:34 -0500
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nBIJSCaU145704
	for <linux-mm@kvack.org>; Fri, 18 Dec 2009 14:28:12 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nBIJSBcb019860
	for <linux-mm@kvack.org>; Fri, 18 Dec 2009 14:28:12 -0500
Subject: Swap on flash SSDs
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <4B2BD55A.10404@sgi.com>
References: <patchbomb.1261076403@v2.random>
	 <alpine.DEB.2.00.0912171352330.4640@router.home>
	 <4B2A8D83.30305@redhat.com>
	 <alpine.DEB.2.00.0912171402550.4640@router.home>
	 <20091218051210.GA417@elte.hu>
	 <alpine.DEB.2.00.0912181227290.26947@router.home>
	 <1261161677.27372.1629.camel@nimitz>  <4B2BD55A.10404@sgi.com>
Content-Type: text/plain
Date: Fri, 18 Dec 2009 11:28:07 -0800
Message-Id: <1261164487.27372.1735.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mike Travis <travis@sgi.com>
Cc: Christoph Lameter <cl@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

On Fri, 2009-12-18 at 11:17 -0800, Mike Travis wrote:
> Interesting discussion about SSD's.  I was under the impression that with
> the finite number of write cycles to an SSD, that unnecessary writes were
> to be avoided?

I'm no expert, but my impression was that this was a problem with other
devices and with "bare" flash, and mostly when writing to the same place
over and over.

Modern, well-made flash SSDs and other flash devices have wear-leveling
built in so that they wear all of the flash cells evenly.  There's still
a discrete number of writes that they can handle over their life, but it
should be high enough that you don't notice.

http://en.wikipedia.org/wiki/Solid-state_drive

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
