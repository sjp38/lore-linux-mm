Date: Tue, 31 Jul 2007 20:14:08 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 01/14] NUMA: Generic management of nodemasks for various
 purposes
In-Reply-To: <20070731200522.c19b3b95.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0707312006550.22443@schroedinger.engr.sgi.com>
References: <20070727194316.18614.36380.sendpatchset@localhost>
 <20070727194322.18614.68855.sendpatchset@localhost>
 <20070731192241.380e93a0.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0707311946530.6158@schroedinger.engr.sgi.com>
 <20070731200522.c19b3b95.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Lee Schermerhorn <lee.schermerhorn@hp.com>, linux-mm@kvack.org, ak@suse.de, Nishanth Aravamudan <nacc@us.ibm.com>, pj@sgi.com, kxr@sgi.com, Mel Gorman <mel@skynet.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, 31 Jul 2007, Andrew Morton wrote:

> ooookay...   I don't think I want to be the first person who gets
> to do that, so I shall duck them for -mm2.
> 
> I think there were updates pending anyway.   I saw several under-replied-to
> patches from Lee but it wasn't clear it they were relevant to these changes
> or what.

I have not seen those. We also have the issue with slab allocations 
failing on NUMAQ with its HIGHMEM zones. 

Andi wants to drop support for NUMAQ again. Is that possible? NUMA only on 
64 bit?

I have checked the current patchset and the fix into a git archive. 
Those interested in working on this can do a

git pull git://git.kernel.org/pub/scm/linux/kernel/git/christoph/numa.git memoryless_nodes

to get the current patchset (This is a bit rough. Sorry Lee the attribution is screwed
up but we will fix this once I get the hang of it).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
