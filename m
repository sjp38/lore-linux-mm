Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 599366B004F
	for <linux-mm@kvack.org>; Fri, 13 Feb 2009 17:22:04 -0500 (EST)
Received: by fxm13 with SMTP id 13so4248529fxm.14
        for <linux-mm@kvack.org>; Fri, 13 Feb 2009 14:22:02 -0800 (PST)
Date: Sat, 14 Feb 2009 01:28:18 +0300
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: What can OpenVZ do?
Message-ID: <20090213222818.GA17630@x200.localdomain>
References: <1233076092-8660-1-git-send-email-orenl@cs.columbia.edu> <1234285547.30155.6.camel@nimitz> <20090211141434.dfa1d079.akpm@linux-foundation.org> <1234462282.30155.171.camel@nimitz> <1234467035.3243.538.camel@calx> <20090212114207.e1c2de82.akpm@linux-foundation.org> <1234475483.30155.194.camel@nimitz> <20090213102732.GB4608@elte.hu> <20090213113248.GA15275@x200.localdomain> <20090213114503.GG15679@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090213114503.GG15679@elte.hu>
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, containers@lists.linux-foundation.org, hpa@zytor.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, viro@zeniv.linux.org.uk, linux-api@vger.kernel.org, torvalds@linux-foundation.org, tglx@linutronix.de, Pavel Emelyanov <xemul@openvz.org>
List-ID: <linux-mm.kvack.org>

On Fri, Feb 13, 2009 at 12:45:03PM +0100, Ingo Molnar wrote:
> 
> * Alexey Dobriyan <adobriyan@gmail.com> wrote:
> 
> > On Fri, Feb 13, 2009 at 11:27:32AM +0100, Ingo Molnar wrote:
> > > Merging checkpoints instead might give them the incentive to get
> > > their act together.
> > 
> > Knowing how much time it takes to beat CPT back into usable shape every time
> > big kernel rebase is done, OpenVZ/Virtuozzo have every single damn incentive
> > to have CPT mainlined.
> 
> So where is the bottleneck? I suspect the effort in having forward ported
> it across 4 major kernel releases in a single year is already larger than
> the technical effort it would  take to upstream it. Any unreasonable upstream 
> resistence/passivity you are bumping into?

People were busy with netns/containers stuff and OpenVZ/Virtuozzo bugs.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
