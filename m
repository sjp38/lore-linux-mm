Date: Thu, 27 Mar 2008 11:48:48 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: vmalloc: Return page array on vunmap
In-Reply-To: <200803272322.20493.nickpiggin@yahoo.com.au>
Message-ID: <Pine.LNX.4.64.0803271147170.7531@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0803262117320.2794@schroedinger.engr.sgi.com>
 <200803272322.20493.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 27 Mar 2008, Nick Piggin wrote:

> Is this really for something important? Because vmap/vunmap is so slow
> and unscalable that it is pretty well unusable for any kind of dynamic
> allocations. I have mostly rewritten it so it is a lot more scalable,
> but all these little patches will make annoying rejects... Can it wait?

Its necessary for the virtual compound page patchset which relies on 
vmap/vunmap. Is the rewrite available somewhere?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
