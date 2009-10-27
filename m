Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id CF5576B0078
	for <linux-mm@kvack.org>; Mon, 26 Oct 2009 22:43:05 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n9R2h2gG014552
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 27 Oct 2009 11:43:02 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 6495C45DE58
	for <linux-mm@kvack.org>; Tue, 27 Oct 2009 11:43:02 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 43DB845DE54
	for <linux-mm@kvack.org>; Tue, 27 Oct 2009 11:43:02 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id EC7801DB8046
	for <linux-mm@kvack.org>; Tue, 27 Oct 2009 11:43:01 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 8C3351DB8045
	for <linux-mm@kvack.org>; Tue, 27 Oct 2009 11:43:01 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 5/5] ONLY-APPLY-IF-STILL-FAILING Revert 373c0a7e, 8aa7e847: Fix congestion_wait() sync/async vs read/write confusion
In-Reply-To: <1256221356-26049-6-git-send-email-mel@csn.ul.ie>
References: <1256221356-26049-1-git-send-email-mel@csn.ul.ie> <1256221356-26049-6-git-send-email-mel@csn.ul.ie>
Message-Id: <20091026235628.2F7B.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 27 Oct 2009 11:42:59 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Frans Pop <elendil@planet.nl>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, Tobias Oetiker <tobi@oetiker.ch>, "Rafael J. Wysocki" <rjw@sisk.pl>, David Miller <davem@davemloft.net>, Reinette Chatre <reinette.chatre@intel.com>, Kalle Valo <kalle.valo@iki.fi>, David Rientjes <rientjes@google.com>, Mohamed Abbas <mohamed.abbas@intel.com>, Jens Axboe <jens.axboe@oracle.com>, "John W. Linville" <linville@tuxdriver.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>, Greg Kroah-Hartman <gregkh@suse.de>, Stephan von Krawczynski <skraw@ithnet.com>, Kernel Testers List <kernel-testers@vger.kernel.org>, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, "linux-mm@kvack.org\"" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> Testing by Frans Pop indicates that in the 2.6.30..2.6.31 window at
> least that the commits 373c0a7e 8aa7e847 dramatically increased the
> number of GFP_ATOMIC failures that were occuring within a wireless
> driver. It was never isolated which of the changes was the exact problem
> and it's possible it has been fixed since. If problems are still
> occuring with GFP_ATOMIC in 2.6.31-rc5, then this patch should be
> applied to determine if the congestion_wait() callers are still broken.

Oops. no, please no.
8aa7e847 is regression fixing commit. this revert indicate the regression
occur again.
if we really need to revert it, we need to revert 1faa16d2287 too.
however, I doubt this commit really cause regression to iwlan. IOW,
I agree Jens.

I hope to try reproduce this problem on my test environment. Can anyone
please explain reproduce way?
Is special hardware necessary?


----------------------------------------------------
commit 8aa7e847d834ed937a9ad37a0f2ad5b8584c1ab0
Author: Jens Axboe <jens.axboe@oracle.com>
Date:   Thu Jul 9 14:52:32 2009 +0200

    Fix congestion_wait() sync/async vs read/write confusion

    Commit 1faa16d22877f4839bd433547d770c676d1d964c accidentally broke
    the bdi congestion wait queue logic, causing us to wait on congestion
    for WRITE (== 1) when we really wanted BLK_RW_ASYNC (== 0) instead.

    Signed-off-by: Jens Axboe <jens.axboe@oracle.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
