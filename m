Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 459C46B002C
	for <linux-mm@kvack.org>; Wed,  8 Feb 2012 14:27:22 -0500 (EST)
Received: by bkty12 with SMTP id y12so1112077bkt.14
        for <linux-mm@kvack.org>; Wed, 08 Feb 2012 11:27:20 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <op.v9cr9sqm3l0zgt@mpn-glaptop>
References: <1328271538-14502-1-git-send-email-m.szyprowski@samsung.com>
 <1328271538-14502-12-git-send-email-m.szyprowski@samsung.com>
 <20120203140428.GG5796@csn.ul.ie> <CA+K6fF49BQiNer=7Di+gCU_EX4E41q-teXJJUBjEd2xc12-j4w@mail.gmail.com>
 <op.v9cr9sqm3l0zgt@mpn-glaptop>
From: sandeep patil <psandeep.s@gmail.com>
Date: Wed, 8 Feb 2012 11:26:40 -0800
Message-ID: <CA+K6fF7naDkPOK8Dv1gg-4RdrrCC5OTx498nFLxg==PPHz-q6g@mail.gmail.com>
Subject: Re: [Linaro-mm-sig] [PATCH 11/15] mm: trigger page reclaim in
 alloc_contig_range() to stabilize watermarks
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Marek Szyprowski <m.szyprowski@samsung.com>, Ohad Ben-Cohen <ohad@wizery.com>, Daniel Walker <dwalker@codeaurora.org>, Russell King <linux@arm.linux.org.uk>, Arnd Bergmann <arnd@arndb.de>, Jesse Barker <jesse.barker@linaro.org>, Jonathan Corbet <corbet@lwn.net>, linux-kernel@vger.kernel.org, Dave Hansen <dave@linux.vnet.ibm.com>, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, Kyungmin Park <kyungmin.park@samsung.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Rob Clark <rob.clark@linaro.org>, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org

2012/2/8 Michal Nazarewicz <mina86@mina86.com>:
> On Wed, 08 Feb 2012 03:04:18 +0100, sandeep patil <psandeep.s@gmail.com>
> wrote:
>>
>> There's another problem I am facing with zone watermarks and CMA.
>>
>> Test details:
>> Memory =A0: 480 MB of total memory, 128 MB CMA region
>> Test case : around 600 MB of file transfer over USB RNDIS onto target
>> System Load : ftpd with console running on target.
>> No one is doing CMA allocations except for the DMA allocations done by t=
he
>> drivers.
>>
>> Result : After about 300MB transfer, I start getting GFP_ATOMIC
>> allocation failures. =A0This only happens if CMA region is reserved.
>> Total memory available is way above the zone watermarks. So, we ended
>> up starving
>> UNMOVABLE/RECLAIMABLE atomic allocations that cannot fallback on CMA
>> region.
>
>
> This looks like something Mel warned me about. =A0I don't really have a g=
ood
> solution for that yet. ;/

What if we have NR_FREE_CMA_PAGES in vmstat and use them to calculate
__zone_watermark_ok()?
However, it still doesn't solve the problem when we DON'T want to use
NR_FREE_CMA_PAGES in case of MOVABLE allocations.


Sandeep

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
