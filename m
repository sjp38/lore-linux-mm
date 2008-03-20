Date: Thu, 20 Mar 2008 11:32:26 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 7/9] slub: Adjust order boundaries and minimum objects
 per slab.
In-Reply-To: <1205995483.14496.59.camel@ymzhang>
Message-ID: <Pine.LNX.4.64.0803201131500.10474@schroedinger.engr.sgi.com>
References: <20080317230516.078358225@sgi.com>  <20080317230529.474353536@sgi.com>
 <1205995483.14496.59.camel@ymzhang>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Mel Gorman <mel@csn.ul.ie>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 20 Mar 2008, Zhang, Yanmin wrote:

> All min_objects's real values are 4 more than above values, as fls(16)
> is equal to 5. So on 16-core tigerton, min_objects=24 which is between 16 and 32.

Hmmm... Okay that may be fine. Just need to update the docs.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
