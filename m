Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id E056C6B003D
	for <linux-mm@kvack.org>; Mon, 14 Dec 2009 00:59:11 -0500 (EST)
Date: Mon, 14 Dec 2009 06:59:08 +0100 (CET)
From: Tobias Oetiker <tobi@oetiker.ch>
Subject: Re: still getting allocation failures (was Re: [PATCH] vmscan: Stop
 kswapd waiting on congestion when the min watermark is not being met V2)
In-Reply-To: <4e5e476b0912031226i5b0e6cf9hdfd5519182ccdefa@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.0912140646550.12657@sebohet.brgvxre.pu>
References: <20091113142608.33B9.A69D9226@jp.fujitsu.com>  <20091113135443.GF29804@csn.ul.ie>  <20091114023138.3DA5.A69D9226@jp.fujitsu.com>  <20091113181557.GM29804@csn.ul.ie>  <2f11576a0911131033w4a9e6042k3349f0be290a167e@mail.gmail.com>
 <20091113200357.GO29804@csn.ul.ie>  <alpine.DEB.2.00.0911261542500.21450@sebohet.brgvxre.pu>  <alpine.DEB.2.00.0911290834470.20857@sebohet.brgvxre.pu>  <20091202113241.GC1457@csn.ul.ie>  <alpine.DEB.2.00.0912022210220.30023@sebohet.brgvxre.pu>
 <4e5e476b0912031226i5b0e6cf9hdfd5519182ccdefa@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Corrado Zoccolo <czoccolo@gmail.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Frans Pop <elendil@planet.nl>, Jiri Kosina <jkosina@suse.cz>, Sven Geggus <lists@fuchsschwanzdomain.de>, Karol Lewandowski <karol.k.lewandowski@gmail.com>, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Stephan von Krawczynski <skraw@ithnet.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Kernel Testers List <kernel-testers@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Hi Corrado,

Dec 3 Corrado Zoccolo wrote:

> Hi Tobias,
> does the patch in http://lkml.org/lkml/2009/11/30/301 help with your
> high order allocation problems?
> It seems that you have lot of memory, but high order pages do not show up.
> The patch should make them more likely to appear.
> On my machine (that has much less ram than yours), with the patch, I
> always have order-10 pages available.

I have tried it and ... it does not work, the  page allocation
failure still shows. BUT while testing it on two machines I found that it
only shows on on machine. The workload on the two machines is
similar (they both run virtualbox) and also the available memory.

Could it be caused by a hardware driver ?

cheers
tobi

-- 
Tobi Oetiker, OETIKER+PARTNER AG, Aarweg 15 CH-4600 Olten, Switzerland
http://it.oetiker.ch tobi@oetiker.ch ++41 62 775 9902 / sb: -9900

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
