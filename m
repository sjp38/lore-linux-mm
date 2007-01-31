Date: Wed, 31 Jan 2007 12:20:00 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch] mm: make mincore work for general mappings
In-Reply-To: <20070130113720.GA3038@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0701311218390.30567@schroedinger.engr.sgi.com>
References: <20070130113720.GA3038@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 30 Jan 2007, Nick Piggin wrote:

> Make mincore work for anon mappings, nonlinear, and migration entries.
> Based on patch from Linus Torvalds <torvalds@linux-foundation.org>.

There are certain similarities with /proc/pid/numa_maps. See 
mm/mempolicy.c. Could we consolidate the code somehow (maybe also with 
smaps) and have one way of scanning the pages of a process?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
