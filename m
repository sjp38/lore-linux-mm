Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 06A166B023E
	for <linux-mm@kvack.org>; Wed, 19 May 2010 17:45:09 -0400 (EDT)
Date: Wed, 19 May 2010 23:44:59 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 5/5] vmscan: remove may_swap scan control
Message-ID: <20100519214459.GD2868@cmpxchg.org>
References: <20100430222009.379195565@cmpxchg.org>
 <20100430224316.198324471@cmpxchg.org>
 <20100513122935.2161.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100513122935.2161.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 13, 2010 at 12:36:12PM +0900, KOSAKI Motohiro wrote:
> > The may_swap scan control flag can be naturally merged into the
> > swappiness parameter: swap only if swappiness is non-zero.
> 
> Sorry, NAK.
> 
> AFAIK, swappiness==0 is very widely used in MySQL users community.
> They expect this parameter mean "very prefer to discard file cache 
> rather than swap, but not completely disable swap".
> 
> We shouldn't ignore the real world use case. even if it is a bit strange.

Bummer.  It's really ugly to have 'zero' mean 'almost nothing'.

But since swappiness is passed around as an int, I think we can
instead use -1 for 'no swap'.  Let me look into it and send a
follow-up patch for this as well.

Thanks!

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
