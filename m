Date: Thu, 22 Feb 2007 20:55:41 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: SLUB: The unqueued Slab allocator
In-Reply-To: <20070223001653.GA16108@one.firstfloor.org>
Message-ID: <Pine.LNX.4.64.0702222053540.24461@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0702212250271.30485@schroedinger.engr.sgi.com>
 <p73hctecc3l.fsf@bingen.suse.de> <Pine.LNX.4.64.0702221040140.2011@schroedinger.engr.sgi.com>
 <20070223001653.GA16108@one.firstfloor.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 23 Feb 2007, Andi Kleen wrote:

> If you don't cache constructed but free objects then there is no cache
> advantage of constructors/destructors and they would be useless.

SLUB caches those objects as long as they are part of a partially 
allocated slab. If all objects in the slab are freed then the whole slab 
will be freed. SLUB does not keep queues of freed slabs.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
