Date: Mon, 29 Jan 2007 08:50:58 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 1/5] Add a map to to track dirty pages per node
In-Reply-To: <20070128213813.GH33919298@melbourne.sgi.com>
Message-ID: <Pine.LNX.4.64.0701290849380.28200@schroedinger.engr.sgi.com>
References: <20070120031007.17491.33355.sendpatchset@schroedinger.engr.sgi.com>
 <20070120031012.17491.72105.sendpatchset@schroedinger.engr.sgi.com>
 <20070122013110.GN33919298@melbourne.sgi.com>
 <Pine.LNX.4.64.0701221122560.25121@schroedinger.engr.sgi.com>
 <20070128213813.GH33919298@melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Chinner <dgc@sgi.com>
Cc: akpm@osdl.org, Paul Menage <menage@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, Paul Jackson <pj@sgi.com>, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

On Mon, 29 Jan 2007, David Chinner wrote:

> I think you missed my point - when we call into this function, the
> inode _must_ have already had all it's data written back. That is,
> by definition the inode mapping is clean if inode->i_data.nrpages ==
> 0. Hence if we have any dirty nodes, then we have a mismatch between
> the dirty node mask and the inode dirty state.  That is BUG-worthy,
> IMO.

This is the way it is supposed to be. The dirty map is only reset in 
clean_inode() when we know that all pages have been written back.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
