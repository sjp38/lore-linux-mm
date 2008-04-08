Date: Tue, 8 Apr 2008 14:01:12 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 04/18] SLUB: Sort slab cache list and establish maximum
 objects for defrag slabs
In-Reply-To: <20080407231113.855e2ba3.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0804081359240.31230@schroedinger.engr.sgi.com>
References: <20080404230158.365359425@sgi.com> <20080404230226.577197795@sgi.com>
 <20080407231113.855e2ba3.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Mel Gorman <mel@skynet.ie>, andi@firstfloor.org, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

On Mon, 7 Apr 2008, Andrew Morton wrote:

> Use of __read_mostly would be appropriate here.

Lets not proliferate that stuff unnecessarily. Variable is not used in 
hot code paths.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
