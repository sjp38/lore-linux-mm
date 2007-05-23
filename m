Date: Wed, 23 May 2007 10:59:03 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [Patch] memory unplug v3 [0/4]
Message-Id: <20070523105903.ae9c1c37.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0705221133070.29456@schroedinger.engr.sgi.com>
References: <20070522155824.563f5873.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0705221133070.29456@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, mel@csn.ul.ie, y-goto@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Tue, 22 May 2007 11:34:04 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> On Tue, 22 May 2007, KAMEZAWA Hiroyuki wrote:
> 
> >  - user kernelcore=XXX boot option to create ZONE_MOVABLE.
> >    Memory unplug itself can work without ZONE_MOVABLE but it will be
> >    better to use kernelcore= if your section size is big.
> 
> Hmmm.... Sure wish the ZONE_MOVABLE would go away. Isnt there some way to 
> have a dynamic boundary within ZONE_NORMAL?
> 
Hmm. 
1. Assume there is only ZONE_NORMAL.
2. grouping pages into MIGRATE_UNMOVABLE, MOGIRATE_RECLAIMABLE, MIGRATE_MOVABLE.
   Some range of pages can be used "only" for MIGRATE_MOVABLE(+ RECLAIMABLE)
3. page recaliming algorithm should know what type of page they should reclaim.

Current page reclaming is zone-based. So I think adding zone is not a bad option
if we use zone-based reclaiming. 

If I think of a simple way to avoid adding new zone, I'll post it. but not yet.

-Kame
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
