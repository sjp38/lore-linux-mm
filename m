Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 3FB776B13F0
	for <linux-mm@kvack.org>; Tue, 14 Feb 2012 02:57:59 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id C36EF3EE0BC
	for <linux-mm@kvack.org>; Tue, 14 Feb 2012 16:57:57 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id A997E45DE53
	for <linux-mm@kvack.org>; Tue, 14 Feb 2012 16:57:57 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8FDD545DE50
	for <linux-mm@kvack.org>; Tue, 14 Feb 2012 16:57:57 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7FBB61DB8041
	for <linux-mm@kvack.org>; Tue, 14 Feb 2012 16:57:57 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 307651DB803B
	for <linux-mm@kvack.org>; Tue, 14 Feb 2012 16:57:57 +0900 (JST)
Date: Tue, 14 Feb 2012 16:56:16 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCHv21 07/16] mm: page_alloc: change fallbacks array
 handling
Message-Id: <20120214165616.8b8e36f8.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1328895151-5196-8-git-send-email-m.szyprowski@samsung.com>
References: <1328895151-5196-1-git-send-email-m.szyprowski@samsung.com>
	<1328895151-5196-8-git-send-email-m.szyprowski@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Michal Nazarewicz <mina86@mina86.com>, Kyungmin Park <kyungmin.park@samsung.com>, Russell King <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Daniel Walker <dwalker@codeaurora.org>, Mel Gorman <mel@csn.ul.ie>, Arnd Bergmann <arnd@arndb.de>, Jesse Barker <jesse.barker@linaro.org>, Jonathan Corbet <corbet@lwn.net>, Shariq Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Gaignard <benjamin.gaignard@linaro.org>, Rob Clark <rob.clark@linaro.org>, Ohad Ben-Cohen <ohad@wizery.com>

On Fri, 10 Feb 2012 18:32:22 +0100
Marek Szyprowski <m.szyprowski@samsung.com> wrote:

> From: Michal Nazarewicz <mina86@mina86.com>
> 
> This commit adds a row for MIGRATE_ISOLATE type to the fallbacks array
> which was missing from it.  It also, changes the array traversal logic
> a little making MIGRATE_RESERVE an end marker.  The letter change,
> removes the implicit MIGRATE_UNMOVABLE from the end of each row which
> was read by __rmqueue_fallback() function.
> 
> Signed-off-by: Michal Nazarewicz <mina86@mina86.com>
> Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
> Acked-by: Mel Gorman <mel@csn.ul.ie>
> Tested-by: Rob Clark <rob.clark@linaro.org>
> Tested-by: Ohad Ben-Cohen <ohad@wizery.com>
> Tested-by: Benjamin Gaignard <benjamin.gaignard@linaro.org>

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
