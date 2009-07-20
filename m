Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id C066D6B006A
	for <linux-mm@kvack.org>; Mon, 20 Jul 2009 11:27:13 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 4559582C41F
	for <linux-mm@kvack.org>; Mon, 20 Jul 2009 11:46:59 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id ohrswIIMsLxm for <linux-mm@kvack.org>;
	Mon, 20 Jul 2009 11:46:59 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 381FF82C437
	for <linux-mm@kvack.org>; Mon, 20 Jul 2009 11:46:48 -0400 (EDT)
Date: Mon, 20 Jul 2009 11:27:08 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 3/3] add isolate pages vmstat
In-Reply-To: <20090720143838.7481.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.1.10.0907201126390.20389@gentwo.org>
References: <20090717085821.A900.A69D9226@jp.fujitsu.com> <alpine.DEB.1.10.0907171234130.11303@gentwo.org> <20090720143838.7481.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

On Mon, 20 Jul 2009, KOSAKI Motohiro wrote:

> > On Fri, 17 Jul 2009, KOSAKI Motohiro wrote:
> >
> > > > Why do a separate pass over all the migrates pages? Can you add the
> > > > _inc_xx  somewhere after the page was isolated from the lru by calling
> > > > try_to_unmap()?
> > >
> > > calling try_to_unmap()? the pages are isolated before calling migrate_pages().
> > > migrate_pages() have multiple caller. then I put this __inc_xx into top of
> > > migrate_pages().
> >
> > Then put the inc_xxx's where the pages are isolated.
>
> Is there any benefit? Why do we need sprinkle __inc_xx to many place?

Its only needed in one place where the pages are isolated.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
