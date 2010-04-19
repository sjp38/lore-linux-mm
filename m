Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 00FAB6B01EF
	for <linux-mm@kvack.org>; Mon, 19 Apr 2010 11:15:34 -0400 (EDT)
Date: Mon, 19 Apr 2010 16:15:12 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH] mm: disallow direct reclaim page writeback
Message-ID: <20100419151511.GV19264@csn.ul.ie>
References: <20100413202021.GZ13327@think> <20100414014041.GD2493@dastard> <20100414155233.D153.A69D9226@jp.fujitsu.com> <20100414072830.GK2493@dastard> <20100414085132.GJ25756@csn.ul.ie> <20100415013436.GO2493@dastard> <20100415102837.GB10966@csn.ul.ie> <20100415134217.GB3794@think> <20100416150510.GL19264@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100416150510.GL19264@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Chris Mason <chris.mason@oracle.com>, Dave Chinner <david@fromorbit.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 16, 2010 at 04:05:10PM +0100, Mel Gorman wrote:
> > vi fs/direct-reclaim-helper.c, it has a few placeholders for where the
> > real code needs to go....just look for the ~ marks.
> > 
> 
> I must be blind. What tree is this in? I can't see it v2.6.34-rc4,
> mmotm or google.
> 

Bah, Johannes corrected my literal mind. har de har har :)

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
