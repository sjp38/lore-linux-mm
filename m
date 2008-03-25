Date: Tue, 25 Mar 2008 08:51:06 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [11/14] vcompound: Fallbacks for order 1 stack allocations on IA64 and x86
Message-ID: <20080325075106.GF2170@one.firstfloor.org>
References: <20080321061703.921169367@sgi.com> <20080321061726.782068299@sgi.com> <871w63iuap.fsf@basil.nowhere.org> <Pine.LNX.4.64.0803241251360.4218@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0803241251360.4218@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, viro@ftp.linux.org.uk
List-ID: <linux-mm.kvack.org>

On Mon, Mar 24, 2008 at 12:53:19PM -0700, Christoph Lameter wrote:
> On Fri, 21 Mar 2008, Andi Kleen wrote:
> 
> > The traditional reason this was discouraged (people seem to reinvent
> > variants of this patch all the time) was that there used 
> > to be drivers that did __pa() (or equivalent) on stack addresses
> > and that doesn't work with vmalloc pages.
> > 
> > I don't know if such drivers still exist, but such a change
> > is certainly not a no-brainer
> 
> I thought that had been cleaned up because some arches already have 

Someone posted a patch recently that showed that the cdrom layer
does it. Might be more. It is hard to audit a few million lines
of driver code.

> virtually mapped stacks? This could be debugged by testing with
> CONFIG_VFALLBACK_ALWAYS set. Which results in a stack that is always 
> vmalloc'ed and thus the driver should fail.

It might be a subtle failure.

Maybe sparse could be taught to check for this if it happens
in a single function? (cc'ing Al who might have some thoughts
on this). Of course if it happens spread out over multiple
functions sparse wouldn't help neither. 

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
