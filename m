Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 414746B004D
	for <linux-mm@kvack.org>; Wed, 18 Nov 2009 00:27:22 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nAI5RJdZ017279
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 18 Nov 2009 14:27:20 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id A138945DE53
	for <linux-mm@kvack.org>; Wed, 18 Nov 2009 14:27:19 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 72CEB45DE4F
	for <linux-mm@kvack.org>; Wed, 18 Nov 2009 14:27:19 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 52EC81DB8045
	for <linux-mm@kvack.org>; Wed, 18 Nov 2009 14:27:19 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id F08CA1DB803F
	for <linux-mm@kvack.org>; Wed, 18 Nov 2009 14:27:18 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] vmscan: Have kswapd sleep for a short interval and double check it should be asleep fix 1
In-Reply-To: <20091117103420.GX29804@csn.ul.ie>
References: <2f11576a0911140134u21eafa83t9642bb25ccd953de@mail.gmail.com> <20091117103420.GX29804@csn.ul.ie>
Message-Id: <20091118142111.3E12.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 18 Nov 2009 14:27:18 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Frans Pop <elendil@planet.nl>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Tobias Oetiker <tobi@oetiker.ch>, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Stephan von Krawczynski <skraw@ithnet.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Kernel Testers List <kernel-testers@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> When checking if kswapd is sleeping prematurely, all populated zones are
> checked instead of the zones the instance of kswapd is responsible for.
> The counters for kswapd going to sleep prematurely are also named poorly.
> This patch makes kswapd only check its own zones and renames the relevant
> counters.
> 
> This is a fix to the patch
> vmscan-have-kswapd-sleep-for-a-short-interval-and-double-check-it-should-be-asleep.patch
> and is based on top of mmotm-2009-11-13-19-59. It would be preferable if
> Kosaki Motohiro signed off on it as he had comments on the patch but the
> discussion petered out without a solid conclusion.
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>

Looks good to me.
I apologize to bother you by nit for long time.

	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
