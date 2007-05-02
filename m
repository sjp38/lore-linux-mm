Date: Wed, 2 May 2007 10:03:50 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: 2.6.22 -mm merge plans: slub
In-Reply-To: <Pine.LNX.4.64.0705021346170.16517@blonde.wat.veritas.com>
Message-ID: <Pine.LNX.4.64.0705021002040.32271@schroedinger.engr.sgi.com>
References: <20070430162007.ad46e153.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0705011846590.10660@blonde.wat.veritas.com>
 <20070501125559.9ab42896.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0705012101410.26170@blonde.wat.veritas.com>
 <20070501133618.93793687.akpm@linux-foundation.org>
 <Pine.LNX.4.64.0705021346170.16517@blonde.wat.veritas.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2 May 2007, Hugh Dickins wrote:

> But if Linus' tree is to be better than a warehouse to avoid
> awkward merges, I still think we want it to default to on for
> all the architectures, and for most if not all -rcs.

At some point I dream that SLUB could become the default but I thought 
this would take at least 6 month or so. If want to force this now then I 
will certainly have some busy weeks ahead.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
