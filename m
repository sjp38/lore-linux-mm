Date: Tue, 31 Jul 2007 22:07:27 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 01/14] NUMA: Generic management of nodemasks for various
 purposes
Message-Id: <20070731220727.1fd4b699.akpm@linux-foundation.org>
In-Reply-To: <Pine.LNX.4.64.0707312151400.2894@schroedinger.engr.sgi.com>
References: <20070727194316.18614.36380.sendpatchset@localhost>
	<20070727194322.18614.68855.sendpatchset@localhost>
	<20070731192241.380e93a0.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0707311946530.6158@schroedinger.engr.sgi.com>
	<20070731200522.c19b3b95.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0707312006550.22443@schroedinger.engr.sgi.com>
	<20070731203203.2691ca59.akpm@linux-foundation.org>
	<Pine.LNX.4.64.0707312151400.2894@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Lee Schermerhorn <lee.schermerhorn@hp.com>, linux-mm@kvack.org, ak@suse.de, Nishanth Aravamudan <nacc@us.ibm.com>, pj@sgi.com, kxr@sgi.com, Mel Gorman <mel@skynet.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, 31 Jul 2007 21:55:41 -0700 (PDT) Christoph Lameter <clameter@sgi.com> wrote:

> Anyone have a 32 bit NUMA system for testing this out?
> 

test.kernel.org has a NUMAQ

> 
> Available from the git tree at
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/christoph/slab.git memoryless_nodes

Please send 'em against rc1-mm2 (hopefully an hour away, if x86_64 box #2
works) (after runtime testing CONFIG_NUMA=n, please) and I can add them to next -mm
for test.k.o to look at.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
