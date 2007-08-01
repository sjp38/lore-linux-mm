From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH/RFC] Allow selected nodes to be excluded from MPOL_INTERLEAVE masks
Date: Wed, 1 Aug 2007 12:33:01 +0200
References: <1185566878.5069.123.camel@localhost> <1185812028.5492.79.camel@localhost> <20070801101651.GA9113@linux-sh.org>
In-Reply-To: <20070801101651.GA9113@linux-sh.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="ansi_x3.4-1968"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200708011233.02103.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Mundt <lethal@linux-sh.org>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, Christoph Lameter <clameter@sgi.com>, Nishanth Aravamudan <nacc@us.ibm.com>, kxr@sgi.com, akpm@linux-foundation.org, Eric Whitney <eric.whitney@hp.com>
List-ID: <linux-mm.kvack.org>

On Wednesday 01 August 2007 12:16:51 Paul Mundt wrote:

> Well, it's not so much the interleave that's the problem so much as
> _when_ we interleave. The problem with the interleave node mask at system
> init is that the kernel attempts to spread out data structures across
> these nodes, which results in us being completely out of memory by the
> time we get to userspace. After we've booted, supporting MPOL_INTERLEAVE
> is not so much of a problem, applications just have to be careful with
> their allocations.

I assume you got a mostly flat latency machine with a few additional
small nodes for special purposes, right?

Would the problem be solved if you just had a per arch CONFIG
to disable interleaving at boot?  That would be really simple.

-Andi (who is a bit sceptical of more and more boot options) 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
