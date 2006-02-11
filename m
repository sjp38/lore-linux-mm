Date: Sat, 11 Feb 2006 00:39:44 -0600
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: [PATCH] extend usage of lightweight mm counter operations
Message-ID: <20060211063944.GA2908@dmt.cnet>
References: <20060211054922.GA3484@dmt.cnet>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20060211054922.GA3484@dmt.cnet>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <piggin@cyberone.com.au>, Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Err, parts of this are unsafe.

On Fri, Feb 10, 2006 at 11:49:22PM -0600, Marcelo Tosatti wrote:
> 
> Extend usage of Nick's lightweight mm counter operations to:
> 
> - nr_dirty: in __set_page_dirty_nobuffers and __set_page_dirty_buffers,
> where interrupts are disabled due to acquision of mapping->tree_lock.

These are good.

> - nr_page_table_pages: which is never accessed from interrupt context.
> 
> - pgfault/pgmajfault: which are never accessed from interrupt context.

These are buggy due to preemption. Shall a three underscore variant
be created to disable/enable preemption, or what?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
