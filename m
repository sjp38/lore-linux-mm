Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id C353A600762
	for <linux-mm@kvack.org>; Wed,  2 Dec 2009 06:12:53 -0500 (EST)
Date: Wed, 2 Dec 2009 12:07:32 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] Replace page_mapping_inuse() with page_mapped()
Message-ID: <20091202110732.GA8693@cmpxchg.org>
References: <20091202115358.5C4F.A69D9226@jp.fujitsu.com> <4B15D9F8.9090800@redhat.com> <20091202121152.5C52.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091202121152.5C52.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, Hugh Dickins <hugh.dickins@tiscali.co.uk>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>
List-ID: <linux-mm.kvack.org>

On Wed, Dec 02, 2009 at 12:28:26PM +0900, KOSAKI Motohiro wrote:

> From 61340720e6e66b645db8d5410e89fd3b67eda907 Mon Sep 17 00:00:00 2001
> From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Date: Wed, 2 Dec 2009 12:05:26 +0900
> Subject: [PATCH] Replace page_mapping_inuse() with page_mapped()
> 
> page reclaim logic need to distingish mapped and unmapped pages.
> However page_mapping_inuse() don't provide proper test way. it test
> the address space (i.e. file) is mmpad(). Why `page' reclaim need
> care unrelated page's mapped state? it's unrelated.
> 
> Thus, This patch replace page_mapping_inuse() with page_mapped()
> 
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Reviewed-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
