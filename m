Date: Wed, 25 Jul 2007 15:36:24 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: NUMA policy issues with ZONE_MOVABLE
Message-Id: <20070725153624.1c76a375.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0707242120370.3829@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0707242120370.3829@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, ak@suse.de, Mel Gorman <mel@skynet.ie>, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Tue, 24 Jul 2007 21:20:45 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> The outcome of the 2.6.23 merge was surprising. No antifrag but only 
> ZONE_MOVABLE. ZONE_MOVABLE is the highest zone.
> 
> For the NUMA layer this has some weird consequences if ZONE_MOVABLE is populated
> 
> 1. It is the highest zone.
> 
> 2. Thus policy_zone == ZONE_MOVABLE
> 

I'm sorry that I'm not familiar with mempolicy's history. Can I make questions ? 

What was the main purpose of the policy_zone ?

mempolicy can work without policy_zone check ?


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
