Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id A1F336B0005
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 11:50:28 -0400 (EDT)
Date: Tue, 9 Apr 2013 17:50:25 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC 0/3] soft reclaim rework
Message-ID: <20130409155025.GM29860@dhcp22.suse.cz>
References: <1365509595-665-1-git-send-email-mhocko@suse.cz>
 <20130409153742.GL29860@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130409153742.GL29860@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Ying Han <yinghan@google.com>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Glauber Costa <glommer@parallels.com>

On Tue 09-04-13 17:37:42, Michal Hocko wrote:
> On Tue 09-04-13 14:13:12, Michal Hocko wrote:
> [...]
> > 2) kbuild test showed more or less the same results
> > usage_in_bytes
> > Base
> > 		Group A		Group B
> > Median		394817536	395634688
> > 
> > Patches applied
> > median		483481600	302131200
> > 
> > A is kept closer to the soft limit again. There is some fluctuation
> > around the limit because kbuild creates a lot of short lived processes.
> > Base: 	 pgscan_kswapd_dma32 1648718	pgsteal_kswapd_dma32 1510749
> > Patched: pgscan_kswapd_dma32 2042065	pgsteal_kswapd_dma32 1667745
> 
> OK, so I have patched the base version with the patch bellow which
> uncovers soft reclaim scanning and reclaim and guess what:
> Base:	 pgscan_kswapd_dma32 3710092	pgsteal_kswapd_dma32 3225191
> Patched: pgscan_kswapd_dma32 1846700	pgsteal_kswapd_dma32 1442232
> Base:	 pgscan_direct_dma32 2417683	pgsteal_direct_dma32 459702
> Patched: pgscan_direct_dma32 1839331	pgsteal_direct_dma32 244338

Dohh, a dwarf sneaked in and broke my numbers for the base kernel.
I am rerunning the test.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
