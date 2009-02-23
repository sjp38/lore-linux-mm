Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 0B1DA6B007E
	for <linux-mm@kvack.org>; Mon, 23 Feb 2009 04:10:42 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n1N9AeeT020637
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 23 Feb 2009 18:10:40 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id BB03A45DE50
	for <linux-mm@kvack.org>; Mon, 23 Feb 2009 18:10:39 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 895E51EF081
	for <linux-mm@kvack.org>; Mon, 23 Feb 2009 18:10:39 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id D62BD1DB803E
	for <linux-mm@kvack.org>; Mon, 23 Feb 2009 18:10:38 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 6F6211DB8045
	for <linux-mm@kvack.org>; Mon, 23 Feb 2009 18:10:38 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC PATCH 00/20] Cleanup and optimise the page allocator
In-Reply-To: <84144f020902222329u5754f8b1k790809191ac48f4a@mail.gmail.com>
References: <1235344649-18265-1-git-send-email-mel@csn.ul.ie> <84144f020902222329u5754f8b1k790809191ac48f4a@mail.gmail.com>
Message-Id: <20090223180906.47F1.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 23 Feb 2009 18:10:37 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: kosaki.motohiro@jp.fujitsu.com, Mel Gorman <mel@csn.ul.ie>, Linux Memory Management List <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>
List-ID: <linux-mm.kvack.org>

> On Mon, Feb 23, 2009 at 1:17 AM, Mel Gorman <mel@csn.ul.ie> wrote:
> > The complexity of the page allocator has been increasing for some time
> > and it has now reached the point where the SLUB allocator is doing strange
> > tricks to avoid the page allocator. This is obviously bad as it may encourage
> > other subsystems to try avoiding the page allocator as well.
> 
> I'm not an expert on the page allocator but the series looks sane to me.

Yeah!
I also strongly like this patch series.

Unfortunately, I don't have enough time for patch review in this week.
but I expect I can review and test it next week.

thanks.


> 
> Acked-by: Pekka Enberg <penberg@cs.helsinki.fi>
> 
> Yanmin, it would be interesting to know if we still need 8K kmalloc
> caches with these patches applied. :-)
> 
>                                Pekka



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
