Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id B88896B00EE
	for <linux-mm@kvack.org>; Mon, 12 Sep 2011 11:27:28 -0400 (EDT)
Date: Mon, 12 Sep 2011 10:27:25 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 2/2] slub: reduce a variable in __slab_free()
In-Reply-To: <1315559521.31737.799.camel@debian>
Message-ID: <alpine.DEB.2.00.1109121026080.15509@router.home>
References: <1315559521.31737.799.camel@debian>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Alex,Shi" <alex.shi@intel.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "Chen, Tim C" <tim.c.chen@intel.com>, "Huang, Ying" <ying.huang@intel.com>

On Fri, 9 Sep 2011, Alex,Shi wrote:

> After the compxchg, the new.inuse are fixed in __slab_free as a local
> variable, so we don't need a extra variable for it.

True but its an easier read otherwise and the contents are extracted from
the 16 bit value into a long which is easier to handle for the compiler
later. Check to see if there is a code difference due to this patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
