Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 30A226B004F
	for <linux-mm@kvack.org>; Fri, 17 Jul 2009 12:35:07 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 72E7C82C6C4
	for <linux-mm@kvack.org>; Fri, 17 Jul 2009 12:54:27 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id Fp7OQeiKBJbL for <linux-mm@kvack.org>;
	Fri, 17 Jul 2009 12:54:27 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id F33F282C7C2
	for <linux-mm@kvack.org>; Fri, 17 Jul 2009 12:54:15 -0400 (EDT)
Date: Fri, 17 Jul 2009 12:34:49 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 3/3] add isolate pages vmstat
In-Reply-To: <20090717085821.A900.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.1.10.0907171234130.11303@gentwo.org>
References: <20090716095344.9D10.A69D9226@jp.fujitsu.com> <alpine.DEB.1.10.0907161024120.32382@gentwo.org> <20090717085821.A900.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

On Fri, 17 Jul 2009, KOSAKI Motohiro wrote:

> > Why do a separate pass over all the migrates pages? Can you add the
> > _inc_xx  somewhere after the page was isolated from the lru by calling
> > try_to_unmap()?
>
> calling try_to_unmap()? the pages are isolated before calling migrate_pages().
> migrate_pages() have multiple caller. then I put this __inc_xx into top of
> migrate_pages().

Then put the inc_xxx's where the pages are isolated.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
