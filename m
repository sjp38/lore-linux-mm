Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 656C86B0069
	for <linux-mm@kvack.org>; Thu, 17 Jan 2013 04:12:45 -0500 (EST)
Message-ID: <50F7C02D.60305@web.de>
Date: Thu, 17 Jan 2013 10:11:09 +0100
From: Soeren Moch <smoch@web.de>
MIME-Version: 1.0
Subject: Re: [PATCH] ata: sata_mv: fix sg_tbl_pool alignment
References: <20130115165642.GA25500@titan.lakedaemon.net> <20130115175020.GA3764@kroah.com> <20130115201617.GC25500@titan.lakedaemon.net> <20130115215602.GF25500@titan.lakedaemon.net> <50F5F1B7.3040201@web.de> <20130116024014.GH25500@titan.lakedaemon.net> <50F61D86.4020801@web.de> <50F66B1B.40301@web.de> <20130116155045.GI25500@titan.lakedaemon.net> <50F6DDF7.9080605@web.de> <20130116175203.GK25500@titan.lakedaemon.net>
In-Reply-To: <20130116175203.GK25500@titan.lakedaemon.net>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jason Cooper <jason@lakedaemon.net>
Cc: Greg KH <gregkh@linuxfoundation.org>, Thomas Petazzoni <thomas.petazzoni@free-electrons.com>, Andrew Lunn <andrew@lunn.ch>, Arnd Bergmann <arnd@arndb.de>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Kyungmin Park <kyungmin.park@samsung.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, linaro-mm-sig@lists.linaro.org, linux-arm-kernel@lists.infradead.org, Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>

On 16.01.2013 18:52, Jason Cooper wrote:
> On Wed, Jan 16, 2013 at 06:05:59PM +0100, Soeren Moch wrote:
>> On 16.01.2013 16:50, Jason Cooper wrote:
>>> On Wed, Jan 16, 2013 at 09:55:55AM +0100, Soeren Moch wrote:
>>>> On 16.01.2013 04:24, Soeren Moch wrote:
>>>>> On 16.01.2013 03:40, Jason Cooper wrote:
>>>>>> On Wed, Jan 16, 2013 at 01:17:59AM +0100, Soeren Moch wrote:
>>>>>>> On 15.01.2013 22:56, Jason Cooper wrote:
>>>>>>>> On Tue, Jan 15, 2013 at 03:16:17PM -0500, Jason Cooper wrote:
>>>
>>>> OK, I could trigger the error
>>>>    ERROR: 1024 KiB atomic DMA coherent pool is too small!
>>>>    Please increase it with coherent_pool= kernel parameter!
>>>> only with em28xx sticks and sata, dib0700 sticks removed.
>>>
>>> Did you test the reverse scenario?  ie dib0700 with sata_mv and no
>>> em28xx.
>>
>> Maybe I can test this next night.
>
> Please do, this will tell us if it is in the USB drivers or lower
> (something in common).

Until now there is no error with dib0700 + sata, without em28xx.

But to be sure that there is absolutely no problem with this setting
we probably need additional testing hours.
BTW, these dib0700 sticks use usb bulk transfers (and maybe smaller
dma buffers?).

Regards,
Soeren


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
