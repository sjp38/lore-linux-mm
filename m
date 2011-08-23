Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 3A79C6B0169
	for <linux-mm@kvack.org>; Tue, 23 Aug 2011 11:25:16 -0400 (EDT)
Date: Tue, 23 Aug 2011 10:25:12 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [patch 2/2]slub: add a type for slab partial list position
In-Reply-To: <1314059823.29510.19.camel@sli10-conroe>
Message-ID: <alpine.DEB.2.00.1108231023470.21267@router.home>
References: <1314059823.29510.19.camel@sli10-conroe>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shaohua.li@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, penberg@kernel.org, "Shi, Alex" <alex.shi@intel.com>, "Chen, Tim C" <tim.c.chen@intel.com>

On Tue, 23 Aug 2011, Shaohua Li wrote:

> Adding slab to partial list head/tail is sensentive to performance.
> So adding a type to document it to avoid we get it wrong.

I think that if you want to make it more descriptive then using the stats
values (DEACTIVATE_TO_TAIL/HEAD) would avoid having to introduce an
additional enum and it would also avoid the if statement in the stat call.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
