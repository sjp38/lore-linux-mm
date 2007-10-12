Date: Fri, 12 Oct 2007 10:33:16 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH/RFC 3/4] Mem Policy: Fixup Interleave Policy Reference
 Counting
In-Reply-To: <20071012154912.8157.16517.sendpatchset@localhost>
Message-ID: <Pine.LNX.4.64.0710121031220.8605@schroedinger.engr.sgi.com>
References: <20071012154854.8157.51441.sendpatchset@localhost>
 <20071012154912.8157.16517.sendpatchset@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, ak@suse.de, mel@skynet.ie, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Fri, 12 Oct 2007, Lee Schermerhorn wrote:

> Note:  I investigated moving the check for "policy_needs_unref"
> to the mpol_free() wrapper, but this led to nasty circular header
> dependencies.  If we wanted to make mpol_free() an external 
> function, rather than a static inline, I could do this and 
> remove several checks.  I'd still need to keep an explicit
> check in alloc_page_vma() if we want to use a tail-call for
> the fast path.

At a mininum we need to somehow encapsulate these checks that may now have 
to be done in multiple place. This is going to be ugly because it adds
a lot of special casing to policy handling.

Is there some way to put smarts into mpol_get to deal with this?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
