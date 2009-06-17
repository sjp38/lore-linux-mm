Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id DEB9B6B005A
	for <linux-mm@kvack.org>; Wed, 17 Jun 2009 06:06:40 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n5HA6mv4013943
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 17 Jun 2009 19:06:48 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1F62845DE7B
	for <linux-mm@kvack.org>; Wed, 17 Jun 2009 19:06:48 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id BD43C45DE6E
	for <linux-mm@kvack.org>; Wed, 17 Jun 2009 19:06:47 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 96AE6E08009
	for <linux-mm@kvack.org>; Wed, 17 Jun 2009 19:06:47 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 465ECE08003
	for <linux-mm@kvack.org>; Wed, 17 Jun 2009 19:06:47 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 0/3] Fix malloc() stall in zone_reclaim() and bring behaviour more in line with expectations V3
In-Reply-To: <alpine.DEB.1.10.0906161049180.26093@gentwo.org>
References: <20090616134423.GD14241@csn.ul.ie> <alpine.DEB.1.10.0906161049180.26093@gentwo.org>
Message-Id: <20090617190204.99C6.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 17 Jun 2009 19:06:46 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, riel@redhat.com, fengguang.wu@intel.com, linuxram@us.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

> On Tue, 16 Jun 2009, Mel Gorman wrote:
> 
> > I don't have a particular workload in mind to be perfectly honest. I'm just not
> > convinced of the wisdom of trying to unmap pages by default in zone_reclaim()
> > just because the NUMA distances happen to be large.
> 
> zone reclaim = 1 is supposed to be light weight with minimal impact. The
> intend was just to remove potentially unused pagecache pages so that node
> local allocations can succeed again. So lets not unmap pages.

hm, At least major two zone reclaim developer disagree my patch. Thus I have to
agree with you, because I really don't hope to ignore other developer's opnion.

So, as far as I understand, the conclusion of this thread are
  - Drop my patch
  - instead, implement improvement patch of (may_unmap && page_mapped()) case
  - the documentation should be changed
  - it's my homework(?)

Can you agree this?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
