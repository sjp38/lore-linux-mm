Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 61FC46B02C0
	for <linux-mm@kvack.org>; Wed, 14 Dec 2011 01:59:59 -0500 (EST)
Subject: RE: [PATCH 1/3] slub: set a criteria for slub node partial adding
From: "Alex,Shi" <alex.shi@intel.com>
In-Reply-To: <1323845054.2846.18.camel@edumazet-laptop>
References: <1322814189-17318-1-git-send-email-alex.shi@intel.com>
	 <alpine.DEB.2.00.1112020842280.10975@router.home>
	 <1323419402.16790.6105.camel@debian>
	 <alpine.DEB.2.00.1112090203370.12604@chino.kir.corp.google.com>
	 <6E3BC7F7C9A4BF4286DD4C043110F30B67236EED18@shsmsx502.ccr.corp.intel.com>
	 <alpine.DEB.2.00.1112131734070.8593@chino.kir.corp.google.com>
	 <alpine.DEB.2.00.1112131835100.31514@chino.kir.corp.google.com>
	 <1323842761.16790.8295.camel@debian>
	 <1323845054.2846.18.camel@edumazet-laptop>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 14 Dec 2011 14:56:52 +0800
Message-ID: <1323845812.16790.8307.camel@debian>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, "penberg@kernel.org" <penberg@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>


> > Thanks for the data. Real netperf is hard to give enough press on SLUB.
> > but as I mentioned before, I also didn't find real performance change on
> > my loopback netperf testing. 
> > 
> > I retested hackbench again. about 1% performance increase still exists
> > on my 2 sockets SNB/WSM and 4 sockets NHM.  and no performance drop for
> > other machines. 
> > 
> > Christoph, what's comments you like to offer for the results or for this
> > code change? 
> 
> I believe far more aggressive mechanism is needed to help these
> workloads.
> 
> Please note that the COLD/HOT page concept is not very well used in
> kernel, because its not really obvious that some decisions are always
> good (or maybe this is not well known)

Hope Christoph know everything of SLUB. :) 
> 
> We should try to batch things a bit, instead of doing a very small unit
> of work in slow path.
> 
> We now have a very fast fastpath, but inefficient slow path.
> 
> SLAB has a litle cache per cpu, we could add one to SLUB for freed
> objects, not belonging to current slab. This could avoid all these
> activate/deactivate overhead.

Maybe worth to try or maybe Christoph had studied this? 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
