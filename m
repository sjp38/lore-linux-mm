Date: Fri, 23 Feb 2007 01:16:53 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: SLUB: The unqueued Slab allocator
Message-ID: <20070223001653.GA16108@one.firstfloor.org>
References: <Pine.LNX.4.64.0702212250271.30485@schroedinger.engr.sgi.com> <p73hctecc3l.fsf@bingen.suse.de> <Pine.LNX.4.64.0702221040140.2011@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0702221040140.2011@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andi Kleen <andi@firstfloor.org>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Feb 22, 2007 at 10:42:23AM -0800, Christoph Lameter wrote:
> On Thu, 22 Feb 2007, Andi Kleen wrote:
> 
> > >    SLUB does not need a cache reaper for UP systems.
> > 
> > This means constructors/destructors are becomming worthless? 
> > Can you describe your rationale why you think they don't make
> > sense on UP?
> 
> Cache reaping has nothing to do with constructors and destructors. SLUB 
> fully supports constructors and destructors.

If you don't cache constructed but free objects then there is no cache
advantage of constructors/destructors and they would be useless.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
