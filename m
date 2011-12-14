Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id F3F3E6B02AC
	for <linux-mm@kvack.org>; Tue, 13 Dec 2011 21:36:57 -0500 (EST)
Received: by yenq10 with SMTP id q10so321882yen.14
        for <linux-mm@kvack.org>; Tue, 13 Dec 2011 18:36:57 -0800 (PST)
Date: Tue, 13 Dec 2011 18:36:53 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: RE: [PATCH 1/3] slub: set a criteria for slub node partial adding
In-Reply-To: <alpine.DEB.2.00.1112131734070.8593@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1112131835100.31514@chino.kir.corp.google.com>
References: <1322814189-17318-1-git-send-email-alex.shi@intel.com> <alpine.DEB.2.00.1112020842280.10975@router.home> <1323419402.16790.6105.camel@debian> <alpine.DEB.2.00.1112090203370.12604@chino.kir.corp.google.com> <6E3BC7F7C9A4BF4286DD4C043110F30B67236EED18@shsmsx502.ccr.corp.intel.com>
 <alpine.DEB.2.00.1112131734070.8593@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Shi, Alex" <alex.shi@intel.com>
Cc: Christoph Lameter <cl@linux.com>, "penberg@kernel.org" <penberg@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Eric Dumazet <eric.dumazet@gmail.com>

On Tue, 13 Dec 2011, David Rientjes wrote:

> > > 	{
> > > 	        n->nr_partial++;
> > > 	-       if (tail == DEACTIVATE_TO_TAIL)
> > > 	-               list_add_tail(&page->lru, &n->partial);
> > > 	-       else
> > > 	-               list_add(&page->lru, &n->partial);
> > > 	+       list_add_tail(&page->lru, &n->partial);
> > > 	}
> > > 

2 machines (one netserver, one netperf) both with 16 cores, 64GB memory 
with netperf-2.4.5 comparing Linus' -git with and without this patch:

	threads		SLUB		SLUB+patch
	 16		116614		117213 (+0.5%)
	 32		216436		215065 (-0.6%)
	 48		299991		299399 (-0.2%)
	 64		373753		374617 (+0.2%)
	 80		435688		435765 (UNCH)
	 96		494630		496590 (+0.4%)
	112		546766		546259 (-0.1%)

This suggests the difference is within the noise, so this patch neither 
helps nor hurts netperf on my setup, as expected.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
