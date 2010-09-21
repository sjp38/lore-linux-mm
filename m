Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 74FA36B007B
	for <linux-mm@kvack.org>; Mon, 20 Sep 2010 21:10:29 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o8L1AQ1j008734
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 21 Sep 2010 10:10:26 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 76A0F45DE5D
	for <linux-mm@kvack.org>; Tue, 21 Sep 2010 10:10:26 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5048545DE4F
	for <linux-mm@kvack.org>; Tue, 21 Sep 2010 10:10:26 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 223271DB803E
	for <linux-mm@kvack.org>; Tue, 21 Sep 2010 10:10:26 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id C72D01DB803B
	for <linux-mm@kvack.org>; Tue, 21 Sep 2010 10:10:25 +0900 (JST)
Date: Tue, 21 Sep 2010 10:05:22 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: Default zone_reclaim_mode = 1 on NUMA kernel is bad for
 file/email/web servers
Message-Id: <20100921100522.be252b3d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100916184240.3BC9.A69D9226@jp.fujitsu.com>
References: <1284349152.15254.1394658481@webmail.messagingengine.com>
	<20100916184240.3BC9.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: robm@fastmail.fm, linux-kernel@vger.kernel.org, Bron Gondwana <brong@fastmail.fm>, linux-mm <linux-mm@kvack.org>, Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Thu, 16 Sep 2010 19:01:32 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> Yes, sadly intel motherboard turn on zone_reclaim_mode by default. and
> current zone_reclaim_mode doesn't fit file/web server usecase ;-)
> 
> So, I've created new proof concept patch. This doesn't disable zone_reclaim
> at all. Instead, distinguish for file cache and for anon allocation and
> only file cache doesn't use zone-reclaim.
> 
> That said, high-end hpc user often turn on cpuset.memory_spread_page and
> they avoid this issue. But, why don't we consider avoid it by default?
> 
> 
> Rob, I wonder if following patch help you. Could you please try it?
> 
> 
> Subject: [RFC] vmscan: file cache doesn't use zone_reclaim by default
> 

Hm, can't we use migration of file caches rather than pageout in
zone_reclaim_mode ? Doent' it fix anything ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
