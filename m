Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id B3D678D003B
	for <linux-mm@kvack.org>; Mon, 11 Apr 2011 21:01:29 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id EA20E3EE0BB
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 10:01:26 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id CEE7945DE4D
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 10:01:26 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id B250145DE51
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 10:01:26 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id A51A31DB8041
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 10:01:26 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6A3B41DB803E
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 10:01:26 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH resend^2] mm: increase RECLAIM_DISTANCE to 30
In-Reply-To: <1302557371.7286.16607.camel@nimitz>
References: <20110411172004.0361.A69D9226@jp.fujitsu.com> <1302557371.7286.16607.camel@nimitz>
Message-Id: <20110412100129.43F1.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 12 Apr 2011 10:01:25 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Chris McDermott <lcm@linux.vnet.ibm.com>

> On Mon, 2011-04-11 at 17:19 +0900, KOSAKI Motohiro wrote:
> > This patch raise zone_reclaim_mode threshold to 30. 30 don't have
> > specific meaning. but 20 mean one-hop QPI/Hypertransport and such
> > relatively cheap 2-4 socket machine are often used for tradiotional
> > server as above. The intention is, their machine don't use
> > zone_reclaim_mode.
> 
> I know specifically of pieces of x86 hardware that set the information
> in the BIOS to '21' *specifically* so they'll get the zone_reclaim_mode
> behavior which that implies.

Which hardware?
The reason why now we decided to change default is the original bug reporter was using
mere commodity whitebox hardware and very common workload. 
If it is enough commotidy, we have to concern it. but if it is special, we don't care it.
Hardware vendor should fix a firmware.


> They've done performance testing and run very large and scary benchmarks
> to make sure that they _want_ this turned on.  What this means for them
> is that they'll probably be de-optimized, at least on newer versions of
> the kernel.
> 
> If you want to do this for particular systems, maybe _that_'s what we
> should do.  Have a list of specific configurations that need the
> defaults overridden either because they're buggy, or they have an
> unusual hardware configuration not really reflected in the distance
> table.

No. It's no my demand. It's demand from commodity hardware. you can fix
your company firmware, but we can't change commodity ones.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
