Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 5528C6B0047
	for <linux-mm@kvack.org>; Fri,  2 Dec 2011 09:43:56 -0500 (EST)
Date: Fri, 2 Dec 2011 08:43:53 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 1/3] slub: set a criteria for slub node partial adding
In-Reply-To: <1322814189-17318-1-git-send-email-alex.shi@intel.com>
Message-ID: <alpine.DEB.2.00.1112020842280.10975@router.home>
References: <1322814189-17318-1-git-send-email-alex.shi@intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alex Shi <alex.shi@intel.com>
Cc: penberg@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 2 Dec 2011, Alex Shi wrote:

> From: Alex Shi <alexs@intel.com>
>
> Times performance regression were due to slub add to node partial head
> or tail. That inspired me to do tunning on the node partial adding, to
> set a criteria for head or tail position selection when do partial
> adding.
> My experiment show, when used objects is less than 1/4 total objects
> of slub performance will get about 1.5% improvement on netperf loopback
> testing with 2048 clients, wherever on our 4 or 2 sockets platforms,
> includes sandbridge or core2.

The number of free objects in a slab may have nothing to do with cache
hotness of all objects in the slab. You can only be sure that one object
(the one that was freed) is cache hot. Netperf may use them in sequence
and therefore you are likely to get series of frees on the same slab
page. How are other benchmarks affected by this change?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
