Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 8EFF86B004A
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 13:16:50 -0400 (EDT)
Received: by fxm18 with SMTP id 18so2481897fxm.14
        for <linux-mm@kvack.org>; Fri, 10 Jun 2011 10:16:47 -0700 (PDT)
Content-Type: text/plain; charset=utf-8; format=flowed; delsp=yes
Subject: Re: [PATCH 02/10] lib: genalloc: Generic allocator improvements
References: <1307699698-29369-1-git-send-email-m.szyprowski@samsung.com>
 <1307699698-29369-3-git-send-email-m.szyprowski@samsung.com>
 <20110610122451.15af86d1@lxorguk.ukuu.org.uk>
 <000c01cc2769$02669b70$0733d250$%szyprowski@samsung.com>
 <20110610135217.701a2fd2@lxorguk.ukuu.org.uk>
Date: Fri, 10 Jun 2011 19:16:45 +0200
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
From: "Michal Nazarewicz" <mina86@mina86.com>
Message-ID: <op.vwvd972b3l0zgt@mnazarewicz-glaptop>
In-Reply-To: <20110610135217.701a2fd2@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Andrew Morton' <akpm@linux-foundation.org>, 'KAMEZAWA Hiroyuki' <kamezawa.hiroyu@jp.fujitsu.com>, 'Ankita Garg' <ankita@in.ibm.com>, 'Daniel Walker' <dwalker@codeaurora.org>, 'Johan MOSSBERG' <johan.xx.mossberg@stericsson.com>, 'Mel Gorman' <mel@csn.ul.ie>, 'Arnd
 Bergmann' <arnd@arndb.de>, 'Jesse Barker' <jesse.barker@linaro.org>

On Fri, 10 Jun 2011 14:52:17 +0200, Alan Cox <alan@lxorguk.ukuu.org.uk>  
wrote:

>> I plan to replace it with lib/bitmap.c bitmap_* based allocator  
>> (similar like
>> it it is used by dma_declare_coherent_memory() and friends in
>> drivers/base/dma-coherent.c). We need something really simple for CMA  
>> area
>> management.
>>
>> IMHO allocate_resource and friends a bit too heavy here, but good to  
>> know
>> that such allocator also exists.
>
> Not sure I'd class allocate_resource as heavyweight but providing it's
> using something that already exists rather than inventing yet another
> allocator.

genalloc is already in the kernel and is used in a few places, so we
either let everyone use it as they see fit or we deprecate the library.
If we don't deprecate it I see no reason why CMA should not use it.

-- 
Best regards,                                         _     _
.o. | Liege of Serenely Enlightened Majesty of      o' \,=./ `o
..o | Computer Science,  Michal "mina86" Nazarewicz    (o o)
ooo +-----<email/xmpp: mnazarewicz@google.com>-----ooO--(_)--Ooo--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
