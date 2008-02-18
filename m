From: Andi Kleen <ak@suse.de>
Subject: Re: [rfc][patch] mm: scalable vmaps
Date: Mon, 18 Feb 2008 11:04:45 +0100
References: <20080218082219.GA2018@wotan.suse.de>
In-Reply-To: <20080218082219.GA2018@wotan.suse.de>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200802181104.45898.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Jeremy Fitzhardinge <jeremy@goop.org>, David Chinner <dgc@sgi.com>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> One thing that will be common to any high performance vmap implementation,
> however, will be the use of lazy TLB flushing. So I'm mainly interested
> in comments about this. AFAIK, Xen must be able to eliminate these aliases
> on demand, and CPA also doesn't want aliases around even if they don't
> get explicitly referenced by software 

It's not really a requirement by CPA, but one by the hardware. Alias
mappings always need to have the same caching attributes.

> (because the hardware may do a 
> random speculative operation through the TLB).
> 
> So I just wonder if it is enough to provide a (quite heavyweight) function
> to flush aliases? (vm_unmap_aliases)

For CPA that would work currently (calling that function there
if the caching attributes are changed),  although when CPA use is more wide 
spread than it currently is it might be a problem at some point if it is very slow.

> I ripped the not-very-good vunmap batching code out of XFS, and implemented
> the large buffer mapping with vm_map_ram and vm_unmap_ram... along with
> a couple of other tricks, I was able to speed up a large directory workload
> by 20x on a 64 CPU system. Basically I believe vmap/vunmap is actually
> sped up a lot more than 20x on such a system, but I'm running into other
> locks now. vmap is pretty well blown off the profiles.

Cool. Gratulations.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
