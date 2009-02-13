Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 1F1CB6B003D
	for <linux-mm@kvack.org>; Fri, 13 Feb 2009 06:26:36 -0500 (EST)
Received: by fxm13 with SMTP id 13so3425096fxm.14
        for <linux-mm@kvack.org>; Fri, 13 Feb 2009 03:26:34 -0800 (PST)
Date: Fri, 13 Feb 2009 14:32:48 +0300
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: What can OpenVZ do?
Message-ID: <20090213113248.GA15275@x200.localdomain>
References: <1233076092-8660-1-git-send-email-orenl@cs.columbia.edu> <1234285547.30155.6.camel@nimitz> <20090211141434.dfa1d079.akpm@linux-foundation.org> <1234462282.30155.171.camel@nimitz> <1234467035.3243.538.camel@calx> <20090212114207.e1c2de82.akpm@linux-foundation.org> <1234475483.30155.194.camel@nimitz> <20090213102732.GB4608@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090213102732.GB4608@elte.hu>
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, containers@lists.linux-foundation.org, hpa@zytor.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, viro@zeniv.linux.org.uk, linux-api@vger.kernel.org, torvalds@linux-foundation.org, tglx@linutronix.de, Pavel Emelyanov <xemul@openvz.org>
List-ID: <linux-mm.kvack.org>

On Fri, Feb 13, 2009 at 11:27:32AM +0100, Ingo Molnar wrote:
> 
> * Dave Hansen <dave@linux.vnet.ibm.com> wrote:
> 
> > > If so, perhaps that can be used as a guide.  Will the planned feature
> > > have a similar design?  If not, how will it differ?  To what extent can
> > > we use that implementation as a tool for understanding what this new
> > > implementation will look like?
> > 
> > Yes, we can certainly use it as a guide.  However, there are some
> > barriers to being able to do that:
> > 
> > dave@nimitz:~/kernels/linux-2.6-openvz$ git diff v2.6.27.10... | diffstat | tail -1
> >  628 files changed, 59597 insertions(+), 2927 deletions(-)
> > dave@nimitz:~/kernels/linux-2.6-openvz$ git diff v2.6.27.10... | wc 
> >   84887  290855 2308745
> > 
> > Unfortunately, the git tree doesn't have that great of a history.  It
> > appears that the forward-ports are just applications of huge single
> > patches which then get committed into git.  This tree has also
> > historically contained a bunch of stuff not directly related to
> > checkpoint/restart like resource management.
> 
> Really, OpenVZ/Virtuozzo does not seem to have enough incentive to merge
> upstream, they only seem to forward-port, keep their tree messy, do minimal
> work to reduce the cross section to the rest of the kernel (so that they can
> manage the forward ports) but otherwise are happy with their carved-out
> niche market. [which niche is also spiced with some proprietary add-ons,
> last i checked, not exactly the contribution environment that breeds a
> healthy flow of patches towards the upstream kernel.]

Oh, cut the crap!

> Merging checkpoints instead might give them the incentive to get
> their act together.

Knowing how much time it takes to beat CPT back into usable shape every time
big kernel rebase is done, OpenVZ/Virtuozzo have every single damn incentive
to have CPT mainlined.

If someone is afraid of long config options, there are always CONFIG_CPT and
CONFIG_CR available.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
