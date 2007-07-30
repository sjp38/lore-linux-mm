Date: Mon, 30 Jul 2007 14:57:36 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH/RFC] Allow selected nodes to be excluded from MPOL_INTERLEAVE
 masks
In-Reply-To: <1185827546.5492.84.camel@localhost>
Message-ID: <Pine.LNX.4.64.0707301457060.21604@schroedinger.engr.sgi.com>
References: <1185566878.5069.123.camel@localhost>
 <20070728151912.c541aec0.kamezawa.hiroyu@jp.fujitsu.com>
 <1185812028.5492.79.camel@localhost>  <Pine.LNX.4.64.0707301128400.1013@schroedinger.engr.sgi.com>
 <1185827546.5492.84.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, Paul Mundt <lethal@linux-sh.org>, Nishanth Aravamudan <nacc@us.ibm.com>, ak@suse.de, akpm@linux-foundation.org, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

On Mon, 30 Jul 2007, Lee Schermerhorn wrote:

> You mean instead of just listing the no_interleave_nodes node list
> argument which might contain memoryless nodes? 

Right.
List the nodes that have memory but that are no includes in interleave.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
