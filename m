Date: Thu, 17 May 2007 10:04:32 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2.6.21-rc1-mm1] add check_highest_zone to
 build_zonelists_in_zone_order
Message-Id: <20070517100432.94c39067.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1179345459.5867.31.camel@localhost>
References: <1179345459.5867.31.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, apw@shadowen.org, clameter@sgi.com, ak@suse.de, jbarnes@virtuousgeek.org, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Wed, 16 May 2007 15:57:39 -0400
Lee Schermerhorn <Lee.Schermerhorn@hp.com> wrote:

> 
> [PATCH 2.6.21-rc1-mm1] add check_highest_zone to build_zonelists_in_zone_order
> 
> We missed this in the "change zone order" series.  We need to record
> the highest populated zone, just as build_zonelists_node() does.
> Memory policies apply only to this zone.  Without this, we'll be
> applying policy to all zones, including DMA, I think.  Not having
> thought about it much, I can't claim to understand the downside of
> doing so.
> 
> Also, display selected "policy zone" during boot or reconfig
> of zonelist order, if 'NUMA.  Inquiring minds [might] want to know...
> 
> Cleanup:  remove stale comment in set_zonelist_order()
> 
> Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>
>
Acked-By: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
