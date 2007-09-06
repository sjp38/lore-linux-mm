Date: Thu, 6 Sep 2007 15:34:26 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] prevent kswapd from freeing excessive amounts of lowmem
Message-Id: <20070906153426.a173f8e2.akpm@linux-foundation.org>
In-Reply-To: <46E02CF5.3020301@redhat.com>
References: <46DF3545.4050604@redhat.com>
	<20070905182305.e5d08acf.akpm@linux-foundation.org>
	<46E02CF5.3020301@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, safari-kernel@safari.iki.fi
List-ID: <linux-mm.kvack.org>

> On Thu, 06 Sep 2007 12:38:13 -0400 Rik van Riel <riel@redhat.com> wrote:
> Andrew Morton wrote:
> 

(What happened to the other stuff I said?)

> > I guess for a very small upper zone and a very large lower zone this could
> > still put the scan balancing out of whack, fixable by a smarter version of
> > "8*zone->pages_high" but it doesn't seem very likely that this will affect
> > things much.
> > 
> > Why doesn't direct reclaim need similar treatment?
> 
> Because we only go into the direct reclaim path once
> every zone is at or below zone->pages_low, and the
> direct reclaim path will exit once we have freed more
> than swap_cluster_max pages.
> 

hm.  Now I need to remember why direct-reclaim does that :(

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
