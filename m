Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 771206B002D
	for <linux-mm@kvack.org>; Fri, 18 Nov 2011 18:31:33 -0500 (EST)
Received: by bke17 with SMTP id 17so5363761bke.14
        for <linux-mm@kvack.org>; Fri, 18 Nov 2011 15:31:30 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <op.v45u6zyy3l0zgt@mpn-glaptop>
References: <1321634598-16859-1-git-send-email-m.szyprowski@samsung.com>
 <CA+K6fF6SH6BNoKgwArcqvyav4b=C5SGvymo5LS3akfD_yE_beg@mail.gmail.com> <op.v45u6zyy3l0zgt@mpn-glaptop>
From: sandeep patil <psandeep.s@gmail.com>
Date: Fri, 18 Nov 2011 15:30:49 -0800
Message-ID: <CA+K6fF6iDivqmN9kfY34tWNg+g_rYBBmyS_Mxb6gvLuSgA2JyQ@mail.gmail.com>
Subject: Re: [Linaro-mm-sig] [PATCHv17 0/11] Contiguous Memory Allocator
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Daniel Walker <dwalker@codeaurora.org>, Russell King <linux@arm.linux.org.uk>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Jesse Barker <jesse.barker@linaro.org>, Kyungmin Park <kyungmin.park@samsung.com>, Ankita Garg <ankita@in.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

2011/11/18 Michal Nazarewicz <mina86@mina86.com>:
> On Fri, 18 Nov 2011 22:20:48 +0100, sandeep patil <psandeep.s@gmail.com>
> wrote:
>>
>> I am running a simple test to allocate contiguous regions and write a lo=
g
>> on
>> in a file on sdcard simultaneously. I can reproduce this migration failu=
re
>> 100%
>> times with it.
>> when I tracked the pages that failed to migrate, I found them on the
>> buffer head lru
>> list with a reference held on the buffer_head in the page, which
>> causes drop_buffers()
>> to fail.
>>
>> So, i guess my question is, until all the migration failures are
>> tracked down and fixed,
>> is there a plan to retry the contiguous allocation from a new range in
>> the CMA region?
>
> No. =A0Current CMA implementation will stick to the same range of pages a=
lso
> on consequent allocations of the same size.
>

Doesn't that mean the drivers that fail to allocate from contiguous DMA reg=
ion
will fail, if the migration fails?

~ sandeep

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
