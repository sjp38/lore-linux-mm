Date: Tue, 21 Aug 2007 09:58:53 +0100
Subject: Re: [PATCH 4/6] Record how many zones can be safely skipped in the zonelist
Message-ID: <20070821085853.GD29794@skynet.ie>
References: <20070817201647.14792.2690.sendpatchset@skynet.skynet.ie> <20070817201808.14792.13501.sendpatchset@skynet.skynet.ie> <Pine.LNX.4.64.0708171402540.9635@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0708171402540.9635@schroedinger.engr.sgi.com>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Lee.Schermerhorn@hp.com, ak@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On (17/08/07 14:03), Christoph Lameter didst pronounce:
> Is there any performance improvement because of this patch? It looks 
> like processing got more expensive since an additional cacheline needs to 
> be fetches to get the skip factor.
> 

It's a small gain on a few machines. Where I thought it was more likely
to be a win is on x86-64 NUMA machines particularly if the zonelist
ordering was zone order as there would be potentially many nodes to
skip.

Kernbench didn't show up any regressions for the other machines but the
userspace portion of that workload is unlikely to notice the loss of a
cache line.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
