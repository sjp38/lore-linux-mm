Date: Wed, 12 Sep 2007 17:49:23 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 16 of 24] avoid some lock operation in vm fast path
In-Reply-To: <20070912055952.bd5c99d6.akpm@linux-foundation.org>
Message-ID: <Pine.LNX.4.64.0709121746240.4489@schroedinger.engr.sgi.com>
References: <patchbomb.1187786927@v2.random> <b343d1056f356d60de86.1187786943@v2.random>
 <20070912055952.bd5c99d6.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <andrea@suse.de>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

On Wed, 12 Sep 2007, Andrew Morton wrote:

> OK, but we'd normally do this via some little wrapper functions which are
> empty-if-not-numa.

The only leftover function on reclaim_in_progress is to insure that 
zone_reclaim() does not run concurrently. Maybe that can be accomplished 
in a different way?

On the other hand: Maybe we would like to limit concurrent reclaim even 
for direct reclaim. We have some livelock issues because of zone lock 
contention on large boxes that may perhaps improve if we would simply let 
one processor do its freeing job.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
