Date: Thu, 22 Feb 2007 10:42:23 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: SLUB: The unqueued Slab allocator
In-Reply-To: <p73hctecc3l.fsf@bingen.suse.de>
Message-ID: <Pine.LNX.4.64.0702221040140.2011@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0702212250271.30485@schroedinger.engr.sgi.com>
 <p73hctecc3l.fsf@bingen.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 22 Feb 2007, Andi Kleen wrote:

> >    SLUB does not need a cache reaper for UP systems.
> 
> This means constructors/destructors are becomming worthless? 
> Can you describe your rationale why you think they don't make
> sense on UP?

Cache reaping has nothing to do with constructors and destructors. SLUB 
fully supports constructors and destructors.

> > G. Slab merging
> > 
> >    We often have slab caches with similar parameters. SLUB detects those
> >    on bootup and merges them into the corresponding general caches. This
> >    leads to more effective memory use.
> 
> Did you do any tests on what that does to long term memory fragmentation?
> It is against the "object of same type have similar livetime and should
> be clustered together" theory at least.

I have done no tests in that regard and we would have to assess the impact 
that the merging has to overall system behavior.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
