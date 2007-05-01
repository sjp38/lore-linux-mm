Date: Tue, 1 May 2007 14:08:50 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: 2.6.22 -mm merge plans: slub
In-Reply-To: <Pine.LNX.4.64.0705012101410.26170@blonde.wat.veritas.com>
Message-ID: <Pine.LNX.4.64.0705011403470.26819@schroedinger.engr.sgi.com>
References: <20070430162007.ad46e153.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0705011846590.10660@blonde.wat.veritas.com>
 <20070501125559.9ab42896.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0705012101410.26170@blonde.wat.veritas.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 1 May 2007, Hugh Dickins wrote:

> Yes, to me it does.  If it could be defaulted to on throughout the
> -rcs, on every architecture, then I'd say that's "finishing work";
> and we'd be safe knowing we could go back to slab in a hurry if
> needed.  But it hasn't reached that stage yet, I think.

Why would we need to go back to SLAB if we have not switched to SLUB? SLUB 
is marked experimental and not the default.

The only problems that I am aware of is(or was) the issue with arches 
modifying page struct fields of slab pages that SLUB needs for its own 
operations. And I thought it was all fixed since the powerpc guys were 
quiet and the patch was in for i386.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
