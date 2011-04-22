Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 15D6F8D003B
	for <linux-mm@kvack.org>; Fri, 22 Apr 2011 13:00:58 -0400 (EDT)
Subject: Re: [PATCH v3] mm: make expand_downwards symmetrical to
 expand_upwards
From: Pekka Enberg <penberg@kernel.org>
In-Reply-To: <1303480195.2590.2.camel@mulgrave.site>
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
	 <1303480195.2590.2.camel@mulgrave.site>
Content-Type: text/plain; charset="ISO-8859-1"
Date: Fri, 22 Apr 2011 20:00:52 +0300
Message-ID: <1303491652.15231.81.camel@jaguar>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, linux-parisc@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, x86 maintainers <x86@kernel.org>

Hi James,

On Fri, 2011-04-22 at 08:49 -0500, James Bottomley wrote:
> > I'm OK with this Kconfig patch. Can someone send a proper patch with
> > signoffs and such? Do we want to tag this for -stable too?
> 
> I already did here:
> 
> http://marc.info/?l=linux-arch&m=130324857801976
> 
> I got the wrong linux-mm email address, though (I thought you were on
> vger).

Grr, it's a SLUB patch and you didn't CC any of the maintainers! If that
was an attempt to sneak it past me, that's not cool. And if you left it
out by mistake, that's not cool either!

> I've got a parisc specific patch already for this (also for stable), so
> I can just queue this alongside if everyone's OK with that?

Feel free, I'm not subscribed to linux-arch so I don't have the patch in
my inbox at all:

Acked-by: Pekka Enberg <penberg@kernel.org>

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
