Date: Wed, 9 Apr 2008 11:30:56 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH][trivial fix] add "Isolate" migratetype name to /proc/pagetypeinfo.
Message-ID: <20080409103056.GA5872@csn.ul.ie>
References: <2f11576a0804080952n3041e1edw94978843833f0953@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <2f11576a0804080952n3041e1edw94978843833f0953@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On (09/04/08 01:52), KOSAKI Motohiro didst pronounce:
> patch against: 2.6.25-rc8-mm1
> 
> in a5d76b54a3f3a40385d7f76069a2feac9f1bad63 (memory unplug: page
> isolation by KAMEZAWA Hiroyuki), "isolate" migratetype added.
> but unfortunately, it doesn't treat /proc/pagetypeinfo display logic.
> 
> this patch add "Isolate" to pagetype name field.
> 

Acked-by: Mel Gorman <mel@csn.ul.ie>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
