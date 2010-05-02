Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 2A2F86004C0
	for <linux-mm@kvack.org>; Sat,  1 May 2010 22:09:20 -0400 (EDT)
Date: Sat, 1 May 2010 21:06:06 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] - New round-robin rotor for SLAB allocations
In-Reply-To: <20100430135239.7782f6ba.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.2.00.1005012103360.2928@router.home>
References: <20100426210041.GA6580@sgi.com> <20100430135239.7782f6ba.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Fri, 30 Apr 2010, Andrew Morton wrote:

> Why no update to slob and slub?

SLUB does not do things like managing object level NUMAness but relies on
the page allocator to spread page size blocks out. It will only use one
rotor and therefore not skip nodes. The SLAB issues are a result of the
way object level NUMA awareness is implemented there.

SLOB also does not do the SLAB thing and defers to the page allocator.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
