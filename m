Date: Mon, 30 Jul 2007 11:06:45 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: NUMA policy issues with ZONE_MOVABLE
In-Reply-To: <Pine.LNX.4.64.0707301338460.28698@skynet.skynet.ie>
Message-ID: <Pine.LNX.4.64.0707301106250.743@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0707242120370.3829@schroedinger.engr.sgi.com>
 <20070725111646.GA9098@skynet.ie> <Pine.LNX.4.64.0707251212300.8820@schroedinger.engr.sgi.com>
 <20070726132336.GA18825@skynet.ie> <Pine.LNX.4.64.0707261104360.2374@schroedinger.engr.sgi.com>
 <20070726225920.GA10225@skynet.ie> <Pine.LNX.4.64.0707261819530.18210@schroedinger.engr.sgi.com>
 <20070727082046.GA6301@skynet.ie> <20070727154519.GA21614@skynet.ie>
 <20070728162844.9d5b8c6e.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0707281255480.7824@skynet.skynet.ie>
 <20070728231032.2ec7bd35.kamezawa.hiroyu@jp.fujitsu.com>
 <20070728232154.d84f0bcb.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0707301338460.28698@skynet.skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, Lee.Schermerhorn@hp.com, ak@suse.de, akpm@linux-foundation.org, pj@sgi.com
List-ID: <linux-mm.kvack.org>

On Mon, 30 Jul 2007, Mel Gorman wrote:

> The results from kernbench were mixed. Small improves on some machines and
> small regressions on others. I'll keep the patch on the stack and investigate
> it further with other benchmarks.

Optimize the scanning by encodeing the zone type in the pointer.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
