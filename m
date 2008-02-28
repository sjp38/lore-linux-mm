Subject: Re: [PATCH 3/6] Remember what the preferred zone is for
	zone_statistics
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0802271400110.12963@schroedinger.engr.sgi.com>
References: <20080227214708.6858.53458.sendpatchset@localhost>
	 <20080227214728.6858.79000.sendpatchset@localhost>
	 <Pine.LNX.4.64.0802271400110.12963@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Thu, 28 Feb 2008 12:45:54 -0500
Message-Id: <1204220754.5301.17.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@linux-foundation.org, mel@csn.ul.ie, ak@suse.de, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, rientjes@google.com, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Wed, 2008-02-27 at 14:00 -0800, Christoph Lameter wrote:
> > This patch records what the preferred zone is rather than assuming the
> > first zone in the zonelist is it. This simplifies the reading of later
> > patches in this set.
> 
> And is needed for correctness if GFP_THISNODE is used?

Mel can correct me.  

I believe this is needed for MPOL_BIND allocations because we now use
the zonelist for the local node--i.e., the node from which the
allocation takes place--and search for the nearest node in the policy
nodemask that satisfies the allocation.  For the purpose of numa stats,
a "numa_hit" occurs if the allocation succeeds on the first node in the
zone list that is also in the policy nodemask--this is the "preferred
node".

Lee
> 
> Reviewed-by: Christoph Lameter <clameter@sgi.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
