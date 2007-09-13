Date: Wed, 12 Sep 2007 17:55:45 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 19 of 24] cacheline align VM_is_OOM to prevent false
 sharing
In-Reply-To: <20070912133602.GJ21600@v2.random>
Message-ID: <Pine.LNX.4.64.0709121755200.4489@schroedinger.engr.sgi.com>
References: <patchbomb.1187786927@v2.random> <be2fc447cec06990a2a3.1187786946@v2.random>
 <20070912060255.c5b95414.akpm@linux-foundation.org> <20070912133602.GJ21600@v2.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

On Wed, 12 Sep 2007, Andrea Arcangeli wrote:

> On Wed, Sep 12, 2007 at 06:02:55AM -0700, Andrew Morton wrote:
> > I'd suggest __read_mostly.
> 
> Agreed.

Its a global OOM condition that will kill allocations in cpusets that are 
not OOM. Nack.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
