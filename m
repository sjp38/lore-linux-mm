Message-ID: <3ABBC702.AC9C3C92@mvista.com>
Date: Fri, 23 Mar 2001 13:58:26 -0800
From: george anzinger <george@mvista.com>
MIME-Version: 1.0
Subject: Re: [PATCH] Prevent OOM from killing init
References: <Pine.LNX.4.33.0103232026310.31380-100000@rossi.itg.ie>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jakma <paulj@itg.ie>
Cc: Szabolcs Szakacsits <szaka@f-secure.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Stephen Clouse <stephenc@theiqgroup.com>, Guest section DW <dwguest@win.tue.nl>, Rik van Riel <riel@conectiva.com.br>, Patrick O'Rourke <orourke@missioncriticallinux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

What happens if you just make swap VERY large?  Does the system thrash
it self to a virtual standstill?  Is this a possible answer?  Supposedly
you could then sneak in and blow away the bad guys manually ...

George

Paul Jakma wrote:
> 
> On Fri, 23 Mar 2001, Szabolcs Szakacsits wrote:
> 
> > About the "use resource limits!". Yes, this is one solution. The
> > *expensive* solution (admin time, worse resource utilization, etc).
> 
> traditional user limits have worse resource utilisation? think what
> kind of utilisation a guaranteed allocation system would have. instead
> of 128MB, you'd need maybe a GB of RAM and many many GB of swap for
> most systems.
> 
> some hopefully non-ranting points:
> 
> - setting up limits on a RH system takes 1 minute by editing
> /etc/security/limits.conf.
> 
> - Rik's current oom killer may not do a good job now, but it's
> impossible for it to do a /perfect/ job without implementing
> kernel/esp.c.
> 
> - with limits set you will have:
>  - /possible/ underutilisation on some workloads.
>  - chance of hitting Rik's OOM killer reduced to almost nothing.
> 
> no matter how good or bad Rik's killer is, i'd much rather set limits
> and just about /never/ have it invoked.
> 
> more beancounting will make limits more useful (eg global?) and maybe
> dists can start setting up some kind of limits by default at install
> time based on the RAM installed and whether user selected
> server/workstation/etc.. install.
> 
> Then hopefully we can be a little less concerned about how close Rik
> gets to the impossible task of implementing esp.c.
> 
> >         Szaka
> 
> --paulj
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
