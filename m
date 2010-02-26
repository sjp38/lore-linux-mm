Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id D2D926B0047
	for <linux-mm@kvack.org>; Fri, 26 Feb 2010 09:07:45 -0500 (EST)
Date: Fri, 26 Feb 2010 15:08:25 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH] [4/4] SLAB: Fix node add timer race in cache_reap
Message-ID: <20100226140825.GC16335@basil.fritz.box>
References: <20100220090154.GB11287@basil.fritz.box> <alpine.DEB.2.00.1002240949140.26771@router.home> <4B862623.5090608@cs.helsinki.fi> <alpine.DEB.2.00.1002242357450.26099@chino.kir.corp.google.com> <alpine.DEB.2.00.1002251228140.18861@router.home> <alpine.DEB.2.00.1002251315010.3501@chino.kir.corp.google.com> <alpine.DEB.2.00.1002251627040.18861@router.home> <4B87A62E.5030307@cs.helsinki.fi> <20100226114312.GB16335@basil.fritz.box> <84144f021002260435l6de50c0enb3fcc0c8b45d9f20@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <84144f021002260435l6de50c0enb3fcc0c8b45d9f20@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Andi Kleen <andi@firstfloor.org>, Christoph Lameter <cl@linux-foundation.org>, David Rientjes <rientjes@google.com>, Nick Piggin <npiggin@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haicheng.li@intel.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Fri, Feb 26, 2010 at 02:35:24PM +0200, Pekka Enberg wrote:
> On Fri, Feb 26, 2010 at 1:43 PM, Andi Kleen <andi@firstfloor.org> wrote:
> > On Fri, Feb 26, 2010 at 12:45:02PM +0200, Pekka Enberg wrote:
> >> Christoph Lameter kirjoitti:
> >>>> kmalloc_node() in generic kernel code.  All that is done under
> >>>> MEM_GOING_ONLINE and not MEM_ONLINE, which is why I suggest the first and
> >>>> fourth patch in this series may not be necessary if we prevent setting the
> >>>> bit in the nodemask or building the zonelists until the slab nodelists are
> >>>> ready.
> >>>
> >>> That sounds good.
> >>
> >> Andi?
> >
> > Well if Christoph wants to submit a better patch that is tested and solves
> > the problems he can do that.
> 
> Sure.
> 
> > if he doesn't then I think my patch kit which has been tested
> > is the best alternative currently.
> 
> So do you expect me to merge your patches over his objections?

Let's put it like this: i'm sure there a myriad different 
way in all the possible design spaces to change slab to 
make memory hotadd work.

Unless someone gives me a strong reason (e.g. code as submitted
doesn't work or is really unclean) I'm not very motivated to try them
all (also given that slab.c is really legacy code that will
hopefully go away at some point).  

Also there are still other bugs to fix in memory hotadd and I'm focussing
 my efforts on that.

I don't think the patches I submitted are particularly intrusive or 
unclean or broken.

As far as I can see Christoph's proposal was just another way
to do this, but it wasn't clear to me it was better enough
in any way to spend significant time on it.

So yes I would prefer if you merged them as submitted just
to fix the bugs. If someone else comes up with a better way
to do this and submits patches they could still change
to that later.

As for the timer race patch: I cannot make a strong
argument right now that it's needed, on the other hand
a bit of defensive programming also doesn't hurt. But 
if that one is not in I won't cry.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
