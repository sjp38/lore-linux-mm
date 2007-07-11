Date: Wed, 11 Jul 2007 10:35:45 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 10/12] Memoryless nodes: Update memory policy and page
 migration
In-Reply-To: <20070711161653.GN27655@us.ibm.com>
Message-ID: <Pine.LNX.4.64.0707111035290.14201@schroedinger.engr.sgi.com>
References: <20070710215339.110895755@sgi.com> <20070710215456.394842768@sgi.com>
 <20070711164811.e94df898.kamezawa.hiroyu@jp.fujitsu.com>
 <20070711161653.GN27655@us.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, akpm@linux-foundation.org, kxr@sgi.com, linux-mm@kvack.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

On Wed, 11 Jul 2007, Nishanth Aravamudan wrote:

> I think Christoph missed a hunk in the node_memory_map patch, which
> would
> 
> #define node_memory_map node_stats[N_MEMORY]

No. Somehow the patch was not updated. Need to send out a new rev.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
