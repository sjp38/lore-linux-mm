Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id DEC106B0055
	for <linux-mm@kvack.org>; Mon, 20 Jul 2009 01:39:48 -0400 (EDT)
Date: Mon, 20 Jul 2009 14:39:45 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 3/3] add isolate pages vmstat
In-Reply-To: <alpine.DEB.1.10.0907171234130.11303@gentwo.org>
References: <20090717085821.A900.A69D9226@jp.fujitsu.com> <alpine.DEB.1.10.0907171234130.11303@gentwo.org>
Message-Id: <20090720143838.7481.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

> On Fri, 17 Jul 2009, KOSAKI Motohiro wrote:
> 
> > > Why do a separate pass over all the migrates pages? Can you add the
> > > _inc_xx  somewhere after the page was isolated from the lru by calling
> > > try_to_unmap()?
> >
> > calling try_to_unmap()? the pages are isolated before calling migrate_pages().
> > migrate_pages() have multiple caller. then I put this __inc_xx into top of
> > migrate_pages().
> 
> Then put the inc_xxx's where the pages are isolated.

Is there any benefit? Why do we need sprinkle __inc_xx to many place?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
