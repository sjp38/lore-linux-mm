Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 5939C6B009B
	for <linux-mm@kvack.org>; Wed,  6 May 2009 10:20:17 -0400 (EDT)
Date: Wed, 6 May 2009 15:21:00 +0100
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH 2/6] ksm: dont allow overlap memory addresses
 registrations.
Message-ID: <20090506152100.41266e4c@lxorguk.ukuu.org.uk>
In-Reply-To: <20090506140904.GY16078@random.random>
References: <1241475935-21162-1-git-send-email-ieidus@redhat.com>
	<1241475935-21162-2-git-send-email-ieidus@redhat.com>
	<1241475935-21162-3-git-send-email-ieidus@redhat.com>
	<4A00DD4F.8010101@redhat.com>
	<4A015C69.7010600@redhat.com>
	<4A0181EA.3070600@redhat.com>
	<20090506131735.GW16078@random.random>
	<Pine.LNX.4.64.0905061424480.19190@blonde.anvils>
	<20090506140904.GY16078@random.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Hugh Dickins <hugh@veritas.com>, Rik van Riel <riel@redhat.com>, Izik Eidus <ieidus@redhat.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, chrisw@redhat.com, device@lanana.org, linux-mm@kvack.org, nickpiggin@yahoo.com.au
List-ID: <linux-mm.kvack.org>

> the max number of ksm pages that can be allocated at any given time so
> to avoid OOM conditions, like the swap-compress logic that limits the
> swapdevice size to less than ram.

Are those pages accounted for in the vm_overcommit logic, as if you
allocate a big chunk of memory as KSM will do you need the worst case
vm_overcommit behaviour preserved and that means keeping the stats
correct.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
