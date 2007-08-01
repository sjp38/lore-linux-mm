Date: Wed, 1 Aug 2007 10:47:42 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 01/14] NUMA: Generic management of nodemasks for various
 purposes
In-Reply-To: <20070801155803.GG31324@us.ibm.com>
Message-ID: <Pine.LNX.4.64.0708011047160.20795@schroedinger.engr.sgi.com>
References: <20070727194316.18614.36380.sendpatchset@localhost>
 <20070727194322.18614.68855.sendpatchset@localhost>
 <20070731192241.380e93a0.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0707311946530.6158@schroedinger.engr.sgi.com>
 <20070731200522.c19b3b95.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0707312006550.22443@schroedinger.engr.sgi.com>
 <20070801155803.GG31324@us.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Lee Schermerhorn <lee.schermerhorn@hp.com>, linux-mm@kvack.org, ak@suse.de, pj@sgi.com, kxr@sgi.com, Mel Gorman <mel@skynet.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, 1 Aug 2007, Nishanth Aravamudan wrote:

> > I have checked the current patchset and the fix into a git archive. 
> > Those interested in working on this can do a
> > 
> > git pull git://git.kernel.org/pub/scm/linux/kernel/git/christoph/numa.git memoryless_nodes
> > 
> > to get the current patchset (This is a bit rough. Sorry Lee the attribution is screwed
> > up but we will fix this once I get the hang of it).
> 
> Are you sure this is uptodate? Acc'g to gitweb, the last commit was July
> 22... And I don't see a 'memoryless_nodes' ref in `git peek-remote`.

You need to look at the memoryless_nodes branch. Not master.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
