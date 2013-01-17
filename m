Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 0F3A26B0069
	for <linux-mm@kvack.org>; Thu, 17 Jan 2013 08:48:15 -0500 (EST)
Message-ID: <50F800EB.6040104@web.de>
Date: Thu, 17 Jan 2013 14:47:23 +0100
From: Soeren Moch <smoch@web.de>
MIME-Version: 1.0
Subject: Re: [PATCH v2] mm: dmapool: use provided gfp flags for all dma_alloc_coherent()
 calls
References: <20121119144826.f59667b2.akpm@linux-foundation.org> <20130116024014.GH25500@titan.lakedaemon.net> <50F61D86.4020801@web.de> <201301171049.30415.arnd@arndb.de>
In-Reply-To: <201301171049.30415.arnd@arndb.de>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: Jason Cooper <jason@lakedaemon.net>, Greg KH <gregkh@linuxfoundation.org>, Thomas Petazzoni <thomas.petazzoni@free-electrons.com>, Andrew Lunn <andrew@lunn.ch>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Kyungmin Park <kyungmin.park@samsung.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, linaro-mm-sig@lists.linaro.org, linux-arm-kernel@lists.infradead.org, Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>

On 17.01.2013 11:49, Arnd Bergmann wrote:
> On Wednesday 16 January 2013, Soeren Moch wrote:
>>>> I will see what I can do here. Is there an easy way to track the buffer
>>>> usage without having to wait for complete exhaustion?
>>>
>>> DMA_API_DEBUG
>>
>> OK, maybe I can try this.
>>>
>
> Any success with this? It should at least tell you if there is a
> memory leak in one of the drivers.

Not yet, sorry. I have to do all the tests in my limited spare time.
Can you tell me what to search for in the debug output?

Soeren

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
