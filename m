Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id C016E8D0040
	for <linux-mm@kvack.org>; Thu, 31 Mar 2011 23:18:44 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 216943EE0AE
	for <linux-mm@kvack.org>; Fri,  1 Apr 2011 12:18:40 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0256D45DE99
	for <linux-mm@kvack.org>; Fri,  1 Apr 2011 12:18:40 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id DE33345DE92
	for <linux-mm@kvack.org>; Fri,  1 Apr 2011 12:18:39 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id D1A3BE18003
	for <linux-mm@kvack.org>; Fri,  1 Apr 2011 12:18:39 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9C00AE08003
	for <linux-mm@kvack.org>; Fri,  1 Apr 2011 12:18:39 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 0/3] Unmapped page cache control (v5)
In-Reply-To: <20110331214033.GA2904@dastard>
References: <20110330052819.8212.1359.stgit@localhost6.localdomain6> <20110331214033.GA2904@dastard>
Message-Id: <20110401121825.A875.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri,  1 Apr 2011 12:18:38 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org, akpm@linux-foundation.org, npiggin@kernel.dk, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, cl@linux.com, kamezawa.hiroyu@jp.fujitsu.com

> On Wed, Mar 30, 2011 at 11:00:26AM +0530, Balbir Singh wrote:
> > 
> > The following series implements page cache control,
> > this is a split out version of patch 1 of version 3 of the
> > page cache optimization patches posted earlier at
> > Previous posting http://lwn.net/Articles/425851/ and analysis
> > at http://lwn.net/Articles/419713/
> > 
> > Detailed Description
> > ====================
> > This patch implements unmapped page cache control via preferred
> > page cache reclaim. The current patch hooks into kswapd and reclaims
> > page cache if the user has requested for unmapped page control.
> > This is useful in the following scenario
> > - In a virtualized environment with cache=writethrough, we see
> >   double caching - (one in the host and one in the guest). As
> >   we try to scale guests, cache usage across the system grows.
> >   The goal of this patch is to reclaim page cache when Linux is running
> >   as a guest and get the host to hold the page cache and manage it.
> >   There might be temporary duplication, but in the long run, memory
> >   in the guests would be used for mapped pages.
> 
> What does this do that "cache=none" for the VMs and using the page
> cache inside the guest doesn't acheive? That avoids double caching
> and doesn't require any new complexity inside the host OS to
> acheive...

Right. 

"cache=none" has no double caching issue and KSM already solved
cross gues cache sharing. So, I _guess_ this is not a core motivation 
of his patch. But I'm not him. I'm not sure.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
