Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 687836B017B
	for <linux-mm@kvack.org>; Mon, 12 Dec 2011 09:35:09 -0500 (EST)
Received: by vbbfn1 with SMTP id fn1so5043997vbb.14
        for <linux-mm@kvack.org>; Mon, 12 Dec 2011 06:35:08 -0800 (PST)
Content-Type: text/plain; charset=utf-8; format=flowed; delsp=yes
Subject: Re: [PATCH 03/11] mm: mmzone: introduce zone_pfn_same_memmap()
References: <1321634598-16859-1-git-send-email-m.szyprowski@samsung.com>
 <1321634598-16859-4-git-send-email-m.szyprowski@samsung.com>
 <20111212141953.GD3277@csn.ul.ie>
Date: Mon, 12 Dec 2011 15:35:03 +0100
MIME-Version: 1.0
Content-Transfer-Encoding: Quoted-Printable
From: "Michal Nazarewicz" <mina86@mina86.com>
Message-ID: <op.v6dr4pj43l0zgt@mpn-glaptop>
In-Reply-To: <20111212141953.GD3277@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>, Mel Gorman <mel@csn.ul.ie>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Kyungmin Park <kyungmin.park@samsung.com>, Russell King <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ankita Garg <ankita@in.ibm.com>, Daniel
 Walker <dwalker@codeaurora.org>, Arnd Bergmann <arnd@arndb.de>, Jesse
 Barker <jesse.barker@linaro.org>, Jonathan Corbet <corbet@lwn.net>, Shariq
 Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>, Dave Hansen <dave@linux.vnet.ibm.com>

> On Fri, Nov 18, 2011 at 05:43:10PM +0100, Marek Szyprowski wrote:
>> From: Michal Nazarewicz <mina86@mina86.com>
>> diff --git a/mm/compaction.c b/mm/compaction.c
>> index 6afae0e..09c9702 100644
>> --- a/mm/compaction.c
>> +++ b/mm/compaction.c
>> @@ -111,7 +111,10 @@ skip:
>>
>>  next:
>>  		pfn +=3D isolated;
>> -		page +=3D isolated;
>> +		if (zone_pfn_same_memmap(pfn - isolated, pfn))
>> +			page +=3D isolated;
>> +		else
>> +			page =3D pfn_to_page(pfn);
>>  	}

On Mon, 12 Dec 2011 15:19:53 +0100, Mel Gorman <mel@csn.ul.ie> wrote:
> Is this necessary?
>
> We are isolating pages, the largest of which is a MAX_ORDER_NR_PAGES
> page.  [...]

This is not true for CMA.

> That said, everywhere else managed to avoid checks like this by always=

> scanning in units of pageblocks. Maybe this should be structured
> the same way to guarantee pfn_valid is called at least per pageblock
> (even though only once per MAX_ORDER_NR_PAGES is necessary).

I'll look into that.

-- =

Best regards,                                         _     _
.o. | Liege of Serenely Enlightened Majesty of      o' \,=3D./ `o
..o | Computer Science,  Micha=C5=82 =E2=80=9Cmina86=E2=80=9D Nazarewicz=
    (o o)
ooo +----<email/xmpp: mpn@google.com>--------------ooO--(_)--Ooo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
