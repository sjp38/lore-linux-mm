Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id C2D2A6B0008
	for <linux-mm@kvack.org>; Wed, 23 Jan 2013 10:33:16 -0500 (EST)
Message-ID: <5100022D.9050106@web.de>
Date: Wed, 23 Jan 2013 16:30:53 +0100
From: Soeren Moch <smoch@web.de>
MIME-Version: 1.0
Subject: Re: [PATCH v2] mm: dmapool: use provided gfp flags for all dma_alloc_coherent()
 calls
References: <20121119144826.f59667b2.akpm@linux-foundation.org> <201301171049.30415.arnd@arndb.de> <50F800EB.6040104@web.de> <201301172026.45514.arnd@arndb.de> <50FABBED.1020905@web.de> <20130119185907.GA20719@lunn.ch>
In-Reply-To: <20130119185907.GA20719@lunn.ch>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Lunn <andrew@lunn.ch>
Cc: Arnd Bergmann <arnd@arndb.de>, Jason Cooper <jason@lakedaemon.net>, Greg KH <gregkh@linuxfoundation.org>, Thomas Petazzoni <thomas.petazzoni@free-electrons.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Kyungmin Park <kyungmin.park@samsung.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, linaro-mm-sig@lists.linaro.org, linux-arm-kernel@lists.infradead.org, Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>

On 19.01.2013 19:59, Andrew Lunn wrote:
>> Please find attached a debug log generated with your patch.
>>
>> I used the sata disk and two em28xx dvb sticks, no other usb devices,
>> no ethernet cable connected, tuners on saa716x-based card not used.
>>
>> What I can see in the log: a lot of coherent mappings from sata_mv
>> and orion_ehci, a few from mv643xx_eth, no other coherent mappings.
>> All coherent mappings are page aligned, some of them (from orion_ehci)
>> are not really small (as claimed in __alloc_from_pool).
>>
>> I don't believe in a memory leak. When I restart vdr (the application
>> utilizing the dvb sticks) then there is enough dma memory available
>> again.
>
> Hi Soeren
>
> We should be able to rule out a leak. Mount debugfg and then:
>
> while [ /bin/true ] ; do cat /debug/dma-api/num_free_entries ; sleep 60 ; done
>
> while you are capturing. See if the number goes down.
>
>        Andrew

Now I built a kernel with debugfs enabled.
It is not clear to me what I can see from the dma-api/num_free_entries 
output. After reboot (vdr running) I see decreasing numbers (3453 3452 
3445 3430...), min_free_entries is lower (3390). Sometimes the output is 
constant for several minutes ( 3396 3396 3396 3396 3396,...)

   Soeren

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
