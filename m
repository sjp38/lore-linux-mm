From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: vmalloc: Return page array on vunmap
Date: Fri, 28 Mar 2008 10:02:51 +1100
References: <Pine.LNX.4.64.0803262117320.2794@schroedinger.engr.sgi.com> <200803272322.20493.nickpiggin@yahoo.com.au> <Pine.LNX.4.64.0803271147170.7531@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0803271147170.7531@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200803281002.52110.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Friday 28 March 2008 05:48, Christoph Lameter wrote:
> On Thu, 27 Mar 2008, Nick Piggin wrote:
> > Is this really for something important? Because vmap/vunmap is so slow
> > and unscalable that it is pretty well unusable for any kind of dynamic
> > allocations. I have mostly rewritten it so it is a lot more scalable,
> > but all these little patches will make annoying rejects... Can it wait?
>
> Its necessary for the virtual compound page patchset which relies on
> vmap/vunmap. Is the rewrite available somewhere?

So can't it just stay with that patchset?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
