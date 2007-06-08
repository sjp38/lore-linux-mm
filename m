Date: Thu, 7 Jun 2007 20:11:37 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH] numa: mempolicy: dynamic interleave map for system init.
In-Reply-To: <20070607200101.827d865c.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0706072010520.26825@schroedinger.engr.sgi.com>
References: <20070607011701.GA14211@linux-sh.org>
 <20070607180108.0eeca877.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0706071942240.26636@schroedinger.engr.sgi.com>
 <20070607200101.827d865c.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Paul Mundt <lethal@linux-sh.org>, linux-mm@kvack.org, ak@suse.de, hugh@veritas.com, lee.schermerhorn@hp.com
List-ID: <linux-mm.kvack.org>

On Thu, 7 Jun 2007, Andrew Morton wrote:

> Failing to support memoryless nodes was a bug, and we should continue to
> take bugfixes for that.

We intentionally did support memoryless nodes on the arch level but not in 
the core in order to avoid these issues.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
