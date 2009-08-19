Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 9BECE6B004D
	for <linux-mm@kvack.org>; Wed, 19 Aug 2009 03:29:36 -0400 (EDT)
Received: by ywh41 with SMTP id 41so5877565ywh.23
        for <linux-mm@kvack.org>; Wed, 19 Aug 2009 00:29:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <18eba5a10908190014q6f903399y30478b4c0a7f256b@mail.gmail.com>
References: <18eba5a10908181841t145e4db1wc2daf90f7337aa6e@mail.gmail.com>
	 <20090819114408.ab9c8a78.minchan.kim@barrios-desktop>
	 <4A8B7508.4040001@vflare.org>
	 <20090819135105.e6b69a8d.minchan.kim@barrios-desktop>
	 <18eba5a10908182324x45261d06y83e0f042e9ee6b20@mail.gmail.com>
	 <20090819154958.18a34aa5.minchan.kim@barrios-desktop>
	 <18eba5a10908190014q6f903399y30478b4c0a7f256b@mail.gmail.com>
Date: Wed, 19 Aug 2009 16:29:35 +0900
Message-ID: <28c262360908190029j1153b00fva11c4a215d5932d6@mail.gmail.com>
Subject: Re: abnormal OOM killer message
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Chungki woo <chungki.woo@gmail.com>
Cc: Mel Gorman <mel@csn.ul.ie>, ngupta@vflare.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, fengguang.wu@intel.com, riel@redhat.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Wed, Aug 19, 2009 at 4:14 PM, Chungki woo<chungki.woo@gmail.com> wrote:
>> You means your pages with 79M are swap out in compcache's reserved
>> memory?
>
> Compcache don't have reserved memory.
> When it needs memory, and then allocate memory.

Okay. reserved is not important. :)
My point was that 79M with pages are swap out in compcache swap device ?
Is the number real ?
Can we believe it ?

>
> Thanks.
>



-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
