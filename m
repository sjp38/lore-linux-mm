Date: Mon, 3 Mar 2008 14:26:34 -0500
From: Rik van Riel <riel@redhat.com>
Subject: Re: [patch 09/21] (NEW) improve reclaim balancing
Message-ID: <20080303142634.041d3c66@cuia.boston.redhat.com>
In-Reply-To: <20080301221216.529E.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080228192908.126720629@redhat.com>
	<20080228192928.648701083@redhat.com>
	<20080301221216.529E.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 01 Mar 2008 22:35:44 +0900
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> hi
> 
> > +	/*
> > +	 * Even if we did not try to evict anon pages at all, we want to
> > +	 * rebalance the anon lru active/inactive ratio.
> > +	 */
> > +	if (inactive_anon_low(zone))
> > +		shrink_list(NR_ACTIVE_ANON, SWAP_CLUSTER_MAX, zone, sc,
> > +								priority);
> > +
> 
> you want check global zone status, right?
> if so, this statement only do that at global scan.

Good catch.  I have merged your suggestions.

-- 
All Rights Reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
