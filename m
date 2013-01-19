Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id CD4406B0006
	for <linux-mm@kvack.org>; Sat, 19 Jan 2013 14:02:10 -0500 (EST)
Date: Sat, 19 Jan 2013 19:59:07 +0100
From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v2] mm: dmapool: use provided gfp flags for all
 dma_alloc_coherent() calls
Message-ID: <20130119185907.GA20719@lunn.ch>
References: <20121119144826.f59667b2.akpm@linux-foundation.org>
 <201301171049.30415.arnd@arndb.de>
 <50F800EB.6040104@web.de>
 <201301172026.45514.arnd@arndb.de>
 <50FABBED.1020905@web.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50FABBED.1020905@web.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Soeren Moch <smoch@web.de>
Cc: Arnd Bergmann <arnd@arndb.de>, Jason Cooper <jason@lakedaemon.net>, Greg KH <gregkh@linuxfoundation.org>, Thomas Petazzoni <thomas.petazzoni@free-electrons.com>, Andrew Lunn <andrew@lunn.ch>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Kyungmin Park <kyungmin.park@samsung.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, linaro-mm-sig@lists.linaro.org, linux-arm-kernel@lists.infradead.org, Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>

> Please find attached a debug log generated with your patch.
> 
> I used the sata disk and two em28xx dvb sticks, no other usb devices,
> no ethernet cable connected, tuners on saa716x-based card not used.
> 
> What I can see in the log: a lot of coherent mappings from sata_mv
> and orion_ehci, a few from mv643xx_eth, no other coherent mappings.
> All coherent mappings are page aligned, some of them (from orion_ehci)
> are not really small (as claimed in __alloc_from_pool).
> 
> I don't believe in a memory leak. When I restart vdr (the application
> utilizing the dvb sticks) then there is enough dma memory available
> again.

Hi Soeren

We should be able to rule out a leak. Mount debugfg and then:

while [ /bin/true ] ; do cat /debug/dma-api/num_free_entries ; sleep 60 ; done

while you are capturing. See if the number goes down.

      Andrew

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
