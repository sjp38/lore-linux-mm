Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 67C2C6B0044
	for <linux-mm@kvack.org>; Fri, 18 Dec 2009 13:30:05 -0500 (EST)
Date: Fri, 18 Dec 2009 12:28:50 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 00 of 28] Transparent Hugepage support #2
In-Reply-To: <20091218051210.GA417@elte.hu>
Message-ID: <alpine.DEB.2.00.0912181227290.26947@router.home>
References: <patchbomb.1261076403@v2.random> <alpine.DEB.2.00.0912171352330.4640@router.home> <4B2A8D83.30305@redhat.com> <alpine.DEB.2.00.0912171402550.4640@router.home> <20091218051210.GA417@elte.hu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, "Stephen C. Tweedie" <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

On Fri, 18 Dec 2009, Ingo Molnar wrote:

> Note that it became more relevant in the past few years due to the arrival of
> low-latency, lots-of-iops and cheap SSDs. Even on a low end server you can buy
> a good 160 GB SSD for emergency swap with fantastic latency and for a lot less
> money than 160 GB of real RAM. (which RAM wont even fit physically on typical
> mainboards, is much more expensive and uses up more power and is less
> servicable)

Swap occurs in page size chunks. SSDs may help but its still a desaster
area. You can only realistically use swap in a batch environment. It kills
desktop performance etc etc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
