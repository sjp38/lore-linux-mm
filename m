Date: Tue, 4 Sep 2007 12:23:04 -0700 (PDT)
From: Martin Knoblauch <knobi@knobisoft.de>
Reply-To: knobi@knobisoft.de
Subject: Re: huge improvement with per-device dirty throttling
In-Reply-To: <46DD2760.3040505@wldelft.nl>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Message-ID: <713371.64716.qm@web32603.mail.mud.yahoo.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Leroy van Logchem <leroy.vanlogchem@wldelft.nl>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Peter zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

--- Leroy van Logchem <leroy.vanlogchem@wldelft.nl> wrote:

> Andrea Arcangeli wrote:
> > On Wed, Aug 22, 2007 at 01:05:13PM +0200, Andi Kleen wrote:
> >> Ok perhaps the new adaptive dirty limits helps your single disk
> >> a lot too. But your improvements seem to be more "collateral
> damage" @)
> >>
> >> But if that was true it might be enough to just change the dirty
> limits
> >> to get the same effect on your system. You might want to play with
> >> /proc/sys/vm/dirty_*
> > 
> > The adaptive dirty limit is per task so it can't be reproduced with
> > global sysctl. It made quite some difference when I researched into
> it
> > in function of time. This isn't in function of time but it
> certainly
> > makes a lot of difference too, actually it's the most important
> part
> > of the patchset for most people, the rest is for the corner cases
> that
> > aren't handled right currently (writing to a slow device with
> > writeback cache has always been hanging the whole thing).
> 
> 
> Self-tuning > static sysctl's. The last years we needed to use very 
> small values for dirty_ratio and dirty_background_ratio to soften the
> 
> latency problems we have during sustained writes. Imo these patches 
> really help in many cases, please commit to mainline.
> 
> -- 
> Leroy
> 

 while it helps in some situations, I did some tests today with
2.6.22.6+bdi-v9 (Peter was so kind) which seem to indicate that it
hurts NFS writes. Anyone seen similar effects?

 Otherwise I would just second your request. It definitely helps the
problematic performance of my CCISS based RAID5 volume.

Martin

Martin

------------------------------------------------------
Martin Knoblauch
email: k n o b i AT knobisoft DOT de
www:   http://www.knobisoft.de

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
