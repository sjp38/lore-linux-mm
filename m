Date: Thu, 13 Sep 2007 18:01:56 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/13] Reduce external fragmentation by grouping pages by
 mobility v30
Message-Id: <20070913180156.ee0cdec4.akpm@linux-foundation.org>
In-Reply-To: <20070910112011.3097.8438.sendpatchset@skynet.skynet.ie>
References: <20070910112011.3097.8438.sendpatchset@skynet.skynet.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 10 Sep 2007 12:20:11 +0100 (IST) Mel Gorman <mel@csn.ul.ie> wrote:

> Here is a restacked version of the grouping pages by mobility patches
> based on the patches currently in your tree. It should be  a drop-in
> replacement for what is in 2.6.23-rc4-mm1 and is what I propose for merging
> to mainline.

It really gives me the creeps to throw away a large set of large patches
and to then introduce a new set.

What would go wrong if we just merged the patches I already have?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
