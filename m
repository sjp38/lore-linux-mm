Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id D8A5E6B005C
	for <linux-mm@kvack.org>; Thu, 11 Jun 2009 04:01:56 -0400 (EDT)
Date: Thu, 11 Jun 2009 09:01:37 +0100
From: Andy Whitcroft <apw@canonical.com>
Subject: Re: [PATCH 1/2] lumpy reclaim: clean up and write lumpy reclaim
Message-ID: <20090611080137.GD28011@shadowen.org>
References: <20090610142443.9370aff8.kamezawa.hiroyu@jp.fujitsu.com> <20090610095140.GB25943@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090610095140.GB25943@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, riel@redhat.com, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>

On Wed, Jun 10, 2009 at 10:51:40AM +0100, Mel Gorman wrote:
> On Wed, Jun 10, 2009 at 02:24:43PM +0900, KAMEZAWA Hiroyuki wrote:
> > I think lumpy reclaim should be updated to meet to current split-lru.
> > This patch includes bugfix and cleanup. How do you think ?
> > 
> 
> I think it needs to be split up into its component parts. This patch is
> changing too much and it's very difficult to consider each change in
> isolation.

I can only echo Mels comments here.  It is very hard to review such a
large patch which mostly is fixing a very small change.  This code is
pretty fragile and would need significant testing, I don't know if Mel
is able to run the same tests we used when putting this together in the
first place.

By the looks of the rest of the thread Kame-san is going to break this
up so I'll wait for that.

Thanks!

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
