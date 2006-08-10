Date: Thu, 10 Aug 2006 12:41:37 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [1/3] Add __GFP_THISNODE to avoid fallback to other nodes and
 ignore cpuset/memory policy restrictions.
Message-Id: <20060810124137.6da0fdef.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.64.0608080930380.27620@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0608080930380.27620@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, pj@sgi.com, jes@sgi.com, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

On Tue, 8 Aug 2006 09:33:46 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> Add a new gfp flag __GFP_THISNODE to avoid fallback to other nodes. This flag
> is essential if a kernel component requires memory to be located on a
> certain node. It will be needed for alloc_pages_node() to force allocation
> on the indicated node and for alloc_pages() to force allocation on the
> current node.

This adds a little bit of overhead to non-numa kernels.  I think that
overhead could be eliminated if we were to do

#ifndef CONFIG_NUMA
#define __GFP_THISNODE 0
#endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
