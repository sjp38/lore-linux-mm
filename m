Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 056CB8D003B
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 09:49:59 -0400 (EDT)
Subject: Re: [PATCH v3] mm: make expand_downwards symmetrical to
 expand_upwards
From: James Bottomley <James.Bottomley@HansenPartnership.com>
In-Reply-To: <BANLkTi=JGeWiFm-9H-2vHDsU1v7ykDt1UA@mail.gmail.com>
References: <1303317178.2587.30.camel@mulgrave.site>
	 <alpine.DEB.2.00.1104201410350.31768@chino.kir.corp.google.com>
	 <20110421220351.9180.A69D9226@jp.fujitsu.com>
	 <alpine.DEB.2.00.1104211237250.5829@chino.kir.corp.google.com>
	 <alpine.DEB.2.00.1104211500170.5741@router.home>
	 <alpine.DEB.2.00.1104211411540.20201@chino.kir.corp.google.com>
	 <1303421088.4025.52.camel@mulgrave.site>
	 <alpine.DEB.2.00.1104211431500.20201@chino.kir.corp.google.com>
	 <1303422566.4025.56.camel@mulgrave.site>
	 <alpine.DEB.2.00.1104211505320.20201@chino.kir.corp.google.com>
	 <BANLkTi=JGeWiFm-9H-2vHDsU1v7ykDt1UA@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 22 Apr 2011 08:49:54 -0500
Message-ID: <1303480195.2590.2.camel@mulgrave.site>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-parisc@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, x86 maintainers <x86@kernel.org>

On Fri, 2011-04-22 at 11:02 +0300, Pekka Enberg wrote:
> On Fri, Apr 22, 2011 at 1:12 AM, David Rientjes <rientjes@google.com> wrote:
> >> > diff --git a/init/Kconfig b/init/Kconfig
> >> > index 56240e7..a7ad8fb 100644
> >> > --- a/init/Kconfig
> >> > +++ b/init/Kconfig
> >> > @@ -1226,6 +1226,7 @@ config SLAB
> >> >           per cpu and per node queues.
> >> >
> >> >  config SLUB
> >> > +       depends on BROKEN || NUMA || !DISCONTIGMEM
> >> >         bool "SLUB (Unqueued Allocator)"
> >> >         help
> >> >            SLUB is a slab allocator that minimizes cache line usage
> >>
> >>
> >> I already sent it to linux-arch and there's been no dissent; there have
> >> been a few "will that fix my slub bug?" type of responses.
> >
> > I was concerned about tile because it actually got all this right by using
> > N_NORMAL_MEMORY appropriately and it uses slub by default, but it always
> > enables NUMA at the moment so this won't impact it.
> >
> > Acked-by: David Rientjes <rientjes@google.com>
> 
> I'm OK with this Kconfig patch. Can someone send a proper patch with
> signoffs and such? Do we want to tag this for -stable too?

I already did here:

http://marc.info/?l=linux-arch&m=130324857801976

I got the wrong linux-mm email address, though (I thought you were on
vger).

I've got a parisc specific patch already for this (also for stable), so
I can just queue this alongside if everyone's OK with that?

James


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
