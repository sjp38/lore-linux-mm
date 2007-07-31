Date: Mon, 30 Jul 2007 17:27:41 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [rfc] [patch] mm: zone_reclaim fix for pseudo file systems
In-Reply-To: <20070730172007.ddf7bdee.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0707301725280.25686@schroedinger.engr.sgi.com>
References: <20070727232753.GA10311@localdomain> <20070730132314.f6c8b4e1.akpm@linux-foundation.org>
 <20070731000138.GA32468@localdomain> <20070730172007.ddf7bdee.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ravikiran G Thirumalai <kiran@scalex86.org>, linux-mm@kvack.org, Christoph Lameter <clameter@cthulhu.engr.sgi.com>, shai@scalex86.org
List-ID: <linux-mm.kvack.org>

On Mon, 30 Jul 2007, Andrew Morton wrote:

> The problem is that __zone_reclaim() doesn't use all_unreclaimable at all.
> You'll note that all the other callers of shrink_zone() do take avoiding
> action if the zone is in all_unreclaimable state, but __zone_reclaim() forgot
> to.

zone reclaim only runs if there are unmapped file backed pages that can be 
reclaimed. If the pages are all unreclaimable then they are all mapped and 
global reclaim begins to run. The problem is with global reclaim as far as 
I know.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
