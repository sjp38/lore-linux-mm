From: Andi Kleen <ak@suse.de>
Subject: Re: [TAKE] memory page_alloc zonelist caching speedup
Date: Mon, 16 Oct 2006 11:34:07 +0200
References: <20061010081429.15156.77206.sendpatchset@jackhammer.engr.sgi.com>
In-Reply-To: <20061010081429.15156.77206.sendpatchset@jackhammer.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200610161134.07168.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@osdl.org>, Nick Piggin <nickpiggin@yahoo.com.au>, David Rientjes <rientjes@google.com>, mbligh@google.com, rohitseth@google.com, menage@google.com, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

> 
>  1) Contrary to what I said before, we (SGI, on large ia64 sn2 systems)
>     have seen real customer loads where the cost to scan the zonelist
>     was a problem, due to many nodes being full of memory before
>     we got to a node we could use.  Or at least, I think we have.
>     This was related to me by another engineer, based on experiences
>     from some time past.  So this is not guaranteed.  Most likely, though.

I think some more precise numbers would be appreciated before doing
such changes.

>  - Some per-node data in the struct zonelist is now modified frequently,
>    with no locking.  Multiple CPU cores on a node could hit and mangle
>    this data.  The theory is that this is just performance hint data,
>    and the memory allocator will work just fine despite any such mangling.

Yes but you will add latencies for cache line bounces won't you?
The old zone lists were completely read only. That is what worries me 
most.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
