Date: Thu, 9 Aug 2007 13:19:43 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/3] Use one zonelist per node instead of multiple
 zonelists v2
Message-Id: <20070809131943.64cb0921.akpm@linux-foundation.org>
In-Reply-To: <20070808161504.32320.79576.sendpatchset@skynet.skynet.ie>
References: <20070808161504.32320.79576.sendpatchset@skynet.skynet.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Lee.Schermerhorn@hp.com, pj@sgi.com, ak@suse.de, kamezawa.hiroyu@jp.fujitsu.com, clameter@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed,  8 Aug 2007 17:15:04 +0100 (IST)
Mel Gorman <mel@csn.ul.ie> wrote:

> The following patches replace multiple zonelists per node with one zonelist
> that is filtered based on the GFP flags.

I think I'll duck this for now on im-trying-to-vaguely-stabilize-mm grounds.
Let's go with the horrible-hack for 2.6.23, then revert it and get this
new approach merged and stabilised over the next week or two?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
