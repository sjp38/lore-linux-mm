Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 4828D6B00CE
	for <linux-mm@kvack.org>; Mon, 23 Feb 2009 12:14:23 -0500 (EST)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id E092F82C288
	for <linux-mm@kvack.org>; Mon, 23 Feb 2009 12:18:54 -0500 (EST)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id jM7Hv7WKIKTa for <linux-mm@kvack.org>;
	Mon, 23 Feb 2009 12:18:54 -0500 (EST)
Received: from qirst.com (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 6F73982C34D
	for <linux-mm@kvack.org>; Mon, 23 Feb 2009 12:17:21 -0500 (EST)
Date: Mon, 23 Feb 2009 12:03:50 -0500 (EST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 04/20] Convert gfp_zone() to use a table of precalculated
 value
In-Reply-To: <20090223164047.GO6740@csn.ul.ie>
Message-ID: <alpine.DEB.1.10.0902231203050.25810@qirst.com>
References: <1235344649-18265-1-git-send-email-mel@csn.ul.ie> <1235344649-18265-5-git-send-email-mel@csn.ul.ie> <alpine.DEB.1.10.0902231003090.7298@qirst.com> <200902240241.48575.nickpiggin@yahoo.com.au> <alpine.DEB.1.10.0902231042440.7790@qirst.com>
 <20090223164047.GO6740@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Linux Memory Management List <linux-mm@kvack.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>
List-ID: <linux-mm.kvack.org>

On Mon, 23 Feb 2009, Mel Gorman wrote:

> > Maybe we can come up with a version of gfp_zone that has no branches and
> > no lookup?
> >
>
> Ideally, yes, but I didn't spot any obvious way of figuring it out at
> compile time then or now. Suggestions?

Can we just mask the relevant bits and then find the highest set bit? With
some rearrangement of gfp flags this may work.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
