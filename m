Date: Tue, 8 Apr 2008 23:07:56 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [patch 04/18] SLUB: Sort slab cache list and establish maximum objects for defrag slabs
Message-ID: <20080408210756.GA19010@one.firstfloor.org>
References: <20080404230158.365359425@sgi.com> <20080404230226.577197795@sgi.com> <20080407231113.855e2ba3.akpm@linux-foundation.org> <Pine.LNX.4.64.0804081359240.31230@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0804081359240.31230@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Mel Gorman <mel@skynet.ie>, andi@firstfloor.org, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Tue, Apr 08, 2008 at 02:01:12PM -0700, Christoph Lameter wrote:
> On Mon, 7 Apr 2008, Andrew Morton wrote:
> 
> > Use of __read_mostly would be appropriate here.
> 
> Lets not proliferate that stuff unnecessarily. Variable is not used in 
> hot code paths.

... and the hot paths should eventually move over to immediate values 
once that patch is in

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
