Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 624FB6B0055
	for <linux-mm@kvack.org>; Wed,  8 Jul 2009 17:21:35 -0400 (EDT)
Date: Wed, 8 Jul 2009 14:32:01 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: Performance degradation seen after using one list for
 hot/coldpages.
Message-Id: <20090708143201.efb67493.akpm@linux-foundation.org>
In-Reply-To: <20090708152755.GC14601@csn.ul.ie>
References: <20626261.51271245670323628.JavaMail.weblogic@epml20>
	<20090622165236.GE3981@csn.ul.ie>
	<20090623090630.f06b7b17.kamezawa.hiroyu@jp.fujitsu.com>
	<20090629091542.GC28597@csn.ul.ie>
	<98062A42B4E040F4861C78D172E2499B@sisodomain.com>
	<alpine.DEB.1.10.0907081051570.26162@gentwo.org>
	<20090708152755.GC14601@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: cl@linux-foundation.org, narayanan.g@samsung.com, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

> On Wed, 8 Jul 2009 16:27:55 +0100 Mel Gorman <mel@csn.ul.ie> wrote:
> There are a number of patches that
> I don't believe have made it upstream or into mmotm but I've lost track
> of what is in flight and what isn't. When an mmotm against 2.6.31-rc2 is
> out, I'll be going through it again to see what made it in and resending
> patches as appropriate.

I appear to be stuck in the wrong country again and won't be very
functional until next week, sorry.  As usual, resending stuff doesn't hurt,
especially when that stuff was buried in the middle of a long email trail
under a quite different Subject:.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
