Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id C7015620202
	for <linux-mm@kvack.org>; Fri, 16 Jul 2010 06:27:33 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o6GARVlZ012332
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 16 Jul 2010 19:27:32 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 91A0345DE5D
	for <linux-mm@kvack.org>; Fri, 16 Jul 2010 19:27:31 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6BD0F45DE57
	for <linux-mm@kvack.org>; Fri, 16 Jul 2010 19:27:31 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4E0371DB803F
	for <linux-mm@kvack.org>; Fri, 16 Jul 2010 19:27:31 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 031051DB803E
	for <linux-mm@kvack.org>; Fri, 16 Jul 2010 19:27:31 +0900 (JST)
Date: Fri, 16 Jul 2010 19:22:50 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 6/7] vmscan: convert mm_vmscan_lru_isolate to
 DEFINE_EVENT
Message-Id: <20100716192250.80118098.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100716191649.737B.A69D9226@jp.fujitsu.com>
References: <20100716191006.7369.A69D9226@jp.fujitsu.com>
	<20100716191649.737B.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Nishimura Daisuke <d-nishimura@mtf.biglobe.ne.jp>
List-ID: <linux-mm.kvack.org>

On Fri, 16 Jul 2010 19:17:36 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> 
> TRACE_EVENT() is a bit old fashion and we need to use
> DECLARE_EVENT_CLASS for introducing memcg isolate pages
> tracepoint.
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
