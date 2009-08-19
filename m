Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 9CE156B004D
	for <linux-mm@kvack.org>; Wed, 19 Aug 2009 04:25:37 -0400 (EDT)
Received: by ywh41 with SMTP id 41so5898164ywh.23
        for <linux-mm@kvack.org>; Wed, 19 Aug 2009 01:25:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <28c262360908190029j1153b00fva11c4a215d5932d6@mail.gmail.com>
References: <18eba5a10908181841t145e4db1wc2daf90f7337aa6e@mail.gmail.com>
	 <20090819114408.ab9c8a78.minchan.kim@barrios-desktop>
	 <4A8B7508.4040001@vflare.org>
	 <20090819135105.e6b69a8d.minchan.kim@barrios-desktop>
	 <18eba5a10908182324x45261d06y83e0f042e9ee6b20@mail.gmail.com>
	 <20090819154958.18a34aa5.minchan.kim@barrios-desktop>
	 <18eba5a10908190014q6f903399y30478b4c0a7f256b@mail.gmail.com>
	 <28c262360908190029j1153b00fva11c4a215d5932d6@mail.gmail.com>
Date: Wed, 19 Aug 2009 13:55:44 +0530
Message-ID: <d760cf2d0908190125y1aa033fcx2ff6ebfcbe54356f@mail.gmail.com>
Subject: Re: abnormal OOM killer message
From: Nitin Gupta <ngupta@vflare.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Chungki woo <chungki.woo@gmail.com>, Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, fengguang.wu@intel.com, riel@redhat.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Wed, Aug 19, 2009 at 12:59 PM, Minchan Kim<minchan.kim@gmail.com> wrote:
> On Wed, Aug 19, 2009 at 4:14 PM, Chungki woo<chungki.woo@gmail.com> wrote:
>>> You means your pages with 79M are swap out in compcache's reserved
>>> memory?
>>
>> Compcache don't have reserved memory.
>> When it needs memory, and then allocate memory.
>
> Okay. reserved is not important. :)
> My point was that 79M with pages are swap out in compcache swap device ?
> Is the number real ?
> Can we believe it ?
>


I would suggest moving compcache related discussion over to
linux-mm-cc AT laptop DOT org
as this might not be of such general interest. I would be glad to
discuss your doubts in detail.

See you over there.

Thanks,
Nitin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
