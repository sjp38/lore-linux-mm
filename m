Subject: Re: SLUB: The unqueued Slab allocator
References: <Pine.LNX.4.64.0702212250271.30485@schroedinger.engr.sgi.com>
From: Andi Kleen <andi@firstfloor.org>
Date: 22 Feb 2007 18:54:06 +0100
In-Reply-To: <Pine.LNX.4.64.0702212250271.30485@schroedinger.engr.sgi.com>
Message-ID: <p73hctecc3l.fsf@bingen.suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter <clameter@sgi.com> writes:

> This is a new slab allocator which was motivated by the complexity of the
> with the existing implementation.

Thanks for doing that work. It certainly was long overdue.

> D. SLAB has a complex cache reaper
> 
>    SLUB does not need a cache reaper for UP systems.

This means constructors/destructors are becomming worthless? 
Can you describe your rationale why you think they don't make
sense on UP?

> G. Slab merging
> 
>    We often have slab caches with similar parameters. SLUB detects those
>    on bootup and merges them into the corresponding general caches. This
>    leads to more effective memory use.

Did you do any tests on what that does to long term memory fragmentation?
It is against the "object of same type have similar livetime and should
be clustered together" theory at least.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
