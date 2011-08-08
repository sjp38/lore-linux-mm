Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 89BE46B0169
	for <linux-mm@kvack.org>; Mon,  8 Aug 2011 19:56:18 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 910363EE0BB
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 08:56:15 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7B2B345DE85
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 08:56:15 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 617FA45DE7A
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 08:56:15 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 547981DB802C
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 08:56:15 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 20A171DB803A
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 08:56:15 +0900 (JST)
Date: Tue, 9 Aug 2011 08:48:58 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v2] vmscan: reverse lru scanning order
Message-Id: <20110809084858.cab100e4.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110808110207.30777.30800.stgit@localhost6>
References: <20110727111002.9985.94938.stgit@localhost6>
	<20110808110207.30777.30800.stgit@localhost6>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>

On Mon, 8 Aug 2011 15:02:07 +0400
Konstantin Khlebnikov <khlebnikov@openvz.org> wrote:

> LRU scanning order was accidentially changed in commit v2.6.27-5584-gb69408e:
> "vmscan: Use an indexed array for LRU variables".
> Before that commit reclaimer always scan active lists first.
> 
> This patch just reverse it back.
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>

makes sense...but what real problem do you see ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
