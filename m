Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id E98A56B004D
	for <linux-mm@kvack.org>; Mon, 12 Oct 2009 04:12:39 -0400 (EDT)
Date: Mon, 12 Oct 2009 17:12:32 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 2/2] vmscan: kill shrink_all_zones()
In-Reply-To: <200910112301.29237.rjw@sisk.pl>
References: <20091009175559.12B8.A69D9226@jp.fujitsu.com> <200910112301.29237.rjw@sisk.pl>
Message-Id: <20091012170439.E4CA.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> >   Throuput comparision
> >   ==============================================
> >   old		2192.10 MB/s
> >   new		2222.22 MB/s
> > 
> >   ok, it's almost same throuput.
> > 
> > Cc: Rafael J. Wysocki <rjw@sisk.pl>
> > Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> 
> I have no objections to any of the two patches, but I think we may want to drop
> shrink_all_memory() altogether.  Everything should work without it and the
> reason I didn't remove it was because I saw a performance regression on one
> system without it.  It may not be worth keeping it, though.
> 
> Have you done any tests with shrink_all_memory() removed?

Honestly, I haven't try to remvoe shrink_all_memory() at all. then, I don't have any
mesurement data of shrink_all_memory.
Yes, your opinion seems reasonable. I plan to mesure it awhile after. (sorry, I haven't
enough development time in this month)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
